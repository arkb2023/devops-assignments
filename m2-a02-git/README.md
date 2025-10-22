![Executed from Bash Prompt](https://img.shields.io/badge/Executed-Bash%20Prompt-green?logo=gnu-bash)
![Status: Completed](https://img.shields.io/badge/Status-Completed-brightgreen)

## Module 2: Git Assignment - 2

Tasks To Be Performed:
1. Create a Git working directory with feature1.txt and feature2.txt in the master branch
2. Create 3 branches develop, feature1 and feature2
3. In develop branch create develop.txt, do not stage or commit it
4. Stash this file and check out to feature1 branch
5. Create new.txt file in feature1 branch, stage and commit this file
6. Checkout to develop, unstash this file and commit
7. Please submit all the Git commands used to do the above steps


***

### 1. Create a Git working directory with `feature1.txt` and `feature2.txt` in the master or main branch
```
mkdir test
cd test
git init
# Rename master branch to main
git branch -M main
touch feature1.txt feature2.txt
git add feature1.txt feature2.txt
git commit -m "Add feature1.txt and feature2.txt"
```

*Screenshot: Terminal output shows `feature1.txt` and `feature2.txt` created in main branch*  

![``feature1.txt` and `feature2.txt` in the master branch`](images/01-two-files-in-master-branch-created.png)

---

### 2. Create three branches: `develop`, `feature1`, and `feature2`
```
git branch develop
git branch feature1
git branch feature2
# Verification
git branch        # Should list:main, develop, feature1, feature2
```

*Screenshot: Terminal output after creating three branches (`develop`, `feature1`, and `feature2`) using `git branch*  

![`Create three branches: `develop`, `feature1`, and `feature2``](images/02-3-branches-created.png)



---

### 3. In `develop` branch, create `develop.txt` (do not stage/commit)
```
git checkout develop
touch develop.txt
```
*Screenshot: Terminal shows `develop.txt` created in `develop` branch*  

![`Terminal shows `develop.txt` created in `develop` branch`](images/03-develop-branch-with-file.png)

---

### 4. Stash this file and checkout to `feature1` branch
```
git stash -u        # Save untracked develop.txt, cleans workspace 
git checkout feature1
```

*Screenshot: Result of `git stash -u` stashing `develop.txt` and `git checkout feature1`*


![`Stash this file and checkout to `feature1` branch`](images/04-stashed.png)

---

### 5. Create `new.txt` in `feature1` branch, stage, and commit
```
touch new.txt
git add new.txt
git commit -m "Add new.txt in feature1 branch"
```

*Screenshot: Result of creating, staging, and committing `new.txt` on `feature1` branch*

![`Create `new.txt` in `feature1` branch, stage, and commit`](images/05-file-added-to-feature1-branch-stagged-comitted.png)
---

### 6. Checkout to `develop`, unstash the file, and commit
```bash
git checkout develop
git stash pop     # Restores develop.txt
git add develop.txt
git commit -m "Add develop.txt in develop branch"
```

*Screenshot: Result of switching to `develop`, unstashing `develop.txt`, and committing the file*

![`Checkout to `develop`, unstash the file, and commit`](images/06-unstashed-file-added.png)
