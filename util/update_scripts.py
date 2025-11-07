import os
import sys
import subprocess
import re
import glob
from pathlib import Path
import tempfile
import shutil
import concurrent.futures

def run_command(cmd, cwd=None):
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running command {' '.join(cmd)}: {e}")
        return None

def get_git_default_branch(repo_url):
    try:
        output = run_command(['git', 'remote', 'show', repo_url])
        if output:
            for line in output.splitlines():
                if "HEAD branch:" in line:
                    return line.split(":", 1)[1].strip()
    except Exception as e:
        print(f"Error getting default branch: {e}")
    return None

def update_script(script_path):
    print(f"Processing {script_path}")
    
    with open(script_path, 'r') as f:
        content = f.read()
    
    # Extract variables from the script
    script_vars = {}
    for line in content.splitlines():
        if '=' in line:
            key, value = line.split('=', 1)
            script_vars[key.strip()] = value.strip().strip('"\'')
    
    if script_vars.get('SCRIPT_SKIP'):
        return
    
    for i in [''] + list(range(2, 10)):
        suffix = str(i) if i else ''
        repo_var = f'SCRIPT_REPO{suffix}'
        commit_var = f'SCRIPT_COMMIT{suffix}'
        rev_var = f'SCRIPT_REV{suffix}'
        hgrev_var = f'SCRIPT_HGREV{suffix}'
        branch_var = f'SCRIPT_BRANCH{suffix}'
        tagfilter_var = f'SCRIPT_TAGFILTER{suffix}'
        
        repo = script_vars.get(repo_var)
        if not repo:
            if not suffix:  # First iteration with no suffix
                with open(script_path, 'a') as f:
                    f.write("\nxxx_CHECKME_xxx\n")
                print("Needs manual check.")
            break
        
        current_commit = script_vars.get(commit_var)
        current_rev = script_vars.get(rev_var)
        current_hgrev = script_vars.get(hgrev_var)
        current_branch = script_vars.get(branch_var)
        current_tagfilter = script_vars.get(tagfilter_var)
        
        # SVN Repository
        if current_rev:
            print(f"Checking svn rev for {repo}...")
            cmd = ['svn', '--non-interactive', 'info',
                  '--username', 'anonymous', '--password', '', repo]
            output = run_command(cmd)
            
            if output:
                new_rev = None
                for line in output.splitlines():
                    if line.startswith('Revision:'):
                        new_rev = line.split()[1].strip()
                        break
                
                if new_rev and new_rev != current_rev:
                    print(f"Updating {script_path}")
                    content = re.sub(
                        f'{rev_var}=.*',
                        f'{rev_var}="{new_rev}"',
                        content,
                        flags=re.MULTILINE
                    )
        
        # Mercurial Repository
        elif current_hgrev:
            print(f"Checking hg rev for {repo}...")
            with tempfile.TemporaryDirectory() as tmphgrepo:
                run_command(['hg', 'init'], cwd=tmphgrepo)
                output = run_command(['hg', 'in', '-f', '-n', '-l', '1', repo],
                                  cwd=tmphgrepo)
                
                if output:
                    for line in output.splitlines():
                        if 'changeset' in line:
                            new_hgrev = line.split(':')[2].strip()
                            if new_hgrev != current_hgrev:
                                print(f"Updating {script_path}")
                                content = re.sub(
                                    f'{hgrev_var}=.*',
                                    f'{hgrev_var}="{new_hgrev}"',
                                    content,
                                    flags=re.MULTILINE
                                )
        
        # Git Repository
        elif current_commit:
            if current_tagfilter:
                cmd = ['git', 'ls-remote', '--exit-code', '--tags', '--refs',
                      '--sort=v:refname', repo, f'refs/tags/{current_tagfilter}']
                output = run_command(cmd)
                if output:
                    new_commit = output.splitlines()[-1].split('/')[2].strip()
            else:
                if not current_branch:
                    current_branch = get_git_default_branch(repo)
                    print(f"Found default branch {current_branch}")
                
                if current_branch:
                    cmd = ['git', 'ls-remote', '--exit-code', '--heads', '--refs',
                          repo, f'refs/heads/{current_branch}']
                    output = run_command(cmd)
                    if output:
                        new_commit = output.split()[0]
                        
                        if new_commit != current_commit:
                            print(f"Updating {script_path}")
                            content = re.sub(
                                f'{commit_var}=.*',
                                f'{commit_var}="{new_commit}"',
                                content,
                                flags=re.MULTILINE
                            )
        
        else:
            # Unknown repository type
            with open(script_path, 'a') as f:
                f.write("\nxxx_CHECKME_UNKNOWN_xxx\n")
            print("Unknown layout. Needs manual check.")
            break
    
    with open(script_path, 'w') as f:
        f.write(content)
    print()

def main():
    # Change to the parent directory of the script
    os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    script_files = glob.glob('scripts.d/**/*.sh', recursive=True)
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count() * 4) as executor:
        executor.map(update_script, script_files)

if __name__ == '__main__':
    main()
