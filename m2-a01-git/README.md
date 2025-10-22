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

**Create a new folder and initialize git, put the files in the folder**
```bash
# Create working directory
mkdir m2-a01-git
cd m2-a01-git

# Initialize git
git init

# create files
touch code.txt log.txt output.txt

# Show Untracked Files
git status -uall
```
*Terminal view shows git working directory with unstaged files*  

![`Unstaged files`](images/01-git-working-directory-with-3-untracked-files.png)

**Stage the `Code.txt` and `Output.txt` files**
```bash
git add code.txt output.txt
```
*Terminal view shows 2 staged files*  

![`Two files stages`](images/02-git-2-staged-files.png)

**Commit them**
```bash
git commit -m "Add initial code.txt and output.txt"
```
*Terminal view shows 2 committed files*  

![`Commit files`](images/03-git-2-committed-files.png)


**Push to GitHub**
```bash
# Link remote GitHub repo
git remote add origin git@github.com:arkb2023/m2-a01-git.git

# Verify new remote added
git remote -v

# Push changes to remote and set upstream
git push -u origin master
```

*Terminal view shows 2 files pushed*  

![`Push files to GitHub`](images/04-git-push.png)


*GitHub web interface displaying pushed files in `master` branch*

![`GitHub web interface displaying the new files`](images/05-master-branch-shows-pushed-files-github-view.png)

---