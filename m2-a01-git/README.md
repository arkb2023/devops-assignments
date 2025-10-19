![Executed from Bash Prompt](https://img.shields.io/badge/Executed-Bash%20Prompt-green?logo=gnu-bash)
![Status: Completed](https://img.shields.io/badge/Status-Completed-brightgreen)

## Module 2: Git Assignment - 1

Tasks To Be Performed

1. Based on what you have learnt in the class, do the following steps:
    - a. Create a new folder
    - b. Put the following files in the folder:
        - `Code.txt`
        - `Log.txt`
        - `Output.txt`
    - c. Stage the `Code.txt` and `Output.txt` files
    - d. Commit them
    - e. And finally, push them to GitHub

2. Please share the commands for the above points


***

**a. Create a new folder**
```bash
mkdir test
```
**b. Put the following files in the folder**
```bash
touch test/code.txt test/log.txt test/output.txt
```
*Screenshot with folder and files*  

![`Folder and files`](images/01-folder-with-3-files.png)

**Show Untracked Files**
```bash
git status -uall
```
*Screenshot showing unstaged files*  

![`Unstaged files`](images/02-git-untracked-files.png)

**c. Stage the Code.txt and Output.txt files**
```bash
git add test/code.txt test/output.txt
```
*Screenshot showing 2 staged files*  

![`Two files stages`](images/03-git-2-staged-files.png)

**d. Commit them**
```bash
git commit -m "Add initial code.txt and output.txt"
```
*Screenshot showing 2 committed files*  

![`Commit files`](images/04-git-commit.png)

**e. Push to GitHub**
```bash
git push origin main
```

![`Push files to GitHub`](images/05-git-push.png)


GitHub web interface displaying the new files in `test/` folder

![`GitHub web interface displaying the new files in `test/` folder`](images/06-github-folder-view.png)