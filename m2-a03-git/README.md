![Executed from Bash Prompt](https://img.shields.io/badge/Executed-Bash%20Prompt-green?logo=gnu-bash)
![Status: Completed](https://img.shields.io/badge/Status-Completed-brightgreen)

## Module 2: Git Assignment - 3

Tasks To Be Performed:  
1. Initialize a Git working directory with the following branches:
   - `develop`
   - `f1`
   - `f2`
2. In the `master` branch, create and commit a file named `main.txt`.
3. Put `develop.txt` in `develop` branch, `f1.txt` and `f2.txt` in `f1` and `f2` respectively  
4. Push all these branches to GitHub  
5. On local delete `f2` branch  
6. Delete the same branch on GitHub as well  

### 1. Initialize a Git working directory with the Required Branches (`develop`, `f1`, `f2`)
```bash
mkdir m2-a03-git
cd m2-a03-git
git init
git branch develop
git branch f1
git branch f2
```

*Git Branches `develop`, `f1`, and `f2` Created*  

![`01-3-branches-created.png`](images/01-3-branches-created.png)

### 2. In the `master` (or `main`) Branch, Create and Commit `main.txt`
```bash
git checkout main
touch main.txt
git add main.txt
git commit -m "Add main.txt to main branch"
```

*`main.txt` Committed to `main` Branch*  

![`02-file-added-to-main-branch.png`](images/02-file-added-to-main-branch.png)

### 3. Put `develop.txt` in `develop` branch, `f1.txt` and `f2.txt` in `f1` and `f2` respectively  

**`Develop` Branch**
```bash
git checkout develop
touch develop.txt
git add develop.txt
git commit -m "Add develop.txt to develop branch"
```

*`develop.txt` Committed to `develop` Branch*  

![`03-03-file-added-to-f2-branch.png`](images/03-01-file-added-to-develop-branch.png)

**`f1` Branch**
```bash
git checkout f1
touch f1.txt
git add f1.txt
git commit -m "Add f1.txt to f1 branch"
```

*`f1.txt` Committed to `f1` Branch*  

![`03-03-file-added-to-f2-branch.png`](images/03-02-file-added-to-f1-branch.png)


**`f2` Branch**
```bash
git checkout f2
touch f2.txt
git add f2.txt
git commit -m "Add f2.txt to f2 branch"
```

*`f2.txt` Committed to `f2` Branch*  

![`03-03-file-added-to-f2-branch.png`](images/03-03-file-added-to-f2-branch.png)

### 4. Push All Branches to GitHub
```bash
git push -u origin main
git push -u origin develop
git push -u origin f1
git push -u origin f2
```

*`main` Branch Pushed to GitHub*  

![`04-03-f1-branch-pushed.png`](images/04-01-main-branch-pushed.png)

*`develop` Branch Pushed to GitHub*  

![`04-03-f1-branch-pushed.png`](images/04-02-develop-branch-pushed.png)

*`f1` Branch Pushed to GitHub*  

![`04-03-f1-branch-pushed.png`](images/04-03-f1-branch-pushed.png)

*`f2` Branch Pushed to GitHub*  

![`04-04-f2-branch-pushed.png`](images/04-04-f2-branch-pushed.png)

*GitHub Shows All Four Branches (`main`, `develop`, `f1`, `f2`)*   

![`04-all-4-branches-listed-on-github.png`](images/04-all-4-branches-listed-on-github.png)



### 5. Delete `f2` Locally

```bash
# Switch to another branch first (can’t delete the checked-out one):
git checkout main
git branch -d f2
```
```bash
git branch
```

*`f2` Branch Deleted Locally*  

![`05-f2-branch-deleted-locally.png`](images/05-f2-branch-deleted-locally.png)


### 6. Delete `f2` on GitHub (Remote)
```bash
git push origin --delete f2
```

*`f2` Branch Deleted on GitHub (Remote)*  

![`06-f2-branch-deleted-on-remote-github.png`](images/06-f2-branch-deleted-on-remote-github.png)

*GitHub Confirms `f2` Branch Deletion*  

![`06-f2-branch-deleted-on-remote-github-view.png`](images/06-f2-branch-deleted-on-remote-github-view.png)

