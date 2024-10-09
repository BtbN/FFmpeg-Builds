# Custom

## Modified

To build `win32` target, comparing to `https://github.com/BtbN/FFmpeg-Builds`, this repo changed:

- `.github\workflows\build.yml`
  - Change repo name in `Pre Checks`
  - Make target `win32`
  - Comment Update Wiki -> no Wiki to update in this fork
- `scripts.d\10-mingw.sh`
  - Move to git mirror of mingW, original source returns 403 error then abort the build

    ```YAML
    # SCRIPT_REPO="https://git.code.sf.net/p/mingw-w64/mingw-w64.git"
    # SCRIPT_COMMIT="8f7b5ce363fbfa9d66a38034525cf0fdae4385a3"
    SCRIPT_REPO="https://github.com/mingw-w64/mingw-w64.git"
    # 11.0.0
    # SCRIPT_COMMIT="f9500e2d85b9400c0982518663660a127e1dc61a"
    # 11.0.1
    SCRIPT_COMMIT="c3e587c067a00a561899d49d3e63a659e38802ec"
    # ...
    ```

## Permission

You may encounter error code 126 when running scripts. Error code 126 means script has no execute permission, usually due to file copy & create, especially on Windows.

To add the execute permission:

On Linux or macOS, run:

```Bash
chmod +x file.sh
git add file.sh
git commit
```

On Windows, open git bash, cd to your repo, run:

```Bash
git add --chmod=+x -- file.sh
git commit
```

You need to add commit messages in order to push it. On Windows, git bash will open a vim editor, if you are not familiar with vim:

1. input `i` to use input mode
2. move cursor to a line without `#`, or it will be treated as comment
3. add something, like `Update Permission`
4. press `esc` to return to command mode
5. `:wq`

Note: On Windows, Github desktop can list the permission change but cannot push it with error message `Nothing to commit`, so you must use command line in bash to do the job.

References:

- <https://github.com/orgs/community/discussions/26891>
- <https://stackoverflow.com/questions/74345961/github-actions-permission-denied-when-using-custom-shell>
