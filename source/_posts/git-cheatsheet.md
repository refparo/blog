---
title: Git 速查手册
date: 2016-04-16
tags:
  - 编程
  - 笔记
---

这是 Git 速查手册，专为总是忘记 Git 命令的你准备。

<!-- more -->

* 创建版本库: `git init`
* 添加文件: `git add`
* 提交更改: `git commit -m <message>`
* 查看状态: `git status`
* 查看修改内容: `git diff`
* 查看提交历史: `git log`
    * 查看提交历史(单行): `git log --pretty=oneline`
    * 查看漂亮且清晰明了的提交历史: `git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit`
* 回退
    * 回退到前一个版本: `git reset --hard HEAD^`
    * 回退到前N个版本: `git reset --hard HEAD~<N>`
    * 回退到某次提交: `git reset --hard <commit-id>`
* 查看命令历史: `git reflog`
* 丢弃某文件上一次`git commit`或`git add`后的更改: `git checkout -- <file>`
* 撤销已提交到暂存区的修改: `git reset HEAD <file>`
* 从版本库中删除文件: `git rm <file>`
* 生成ssh-rsa key: `ssh-keygen -t rsa -C "<email>"`
* 关联远程库: `git remote add <repo> <repo>`
* 把某分支的更改推送至远程库: `git push <repo> <branch>`
* 克隆远程库到本地: `git clone <repo>`
* 查看当前所有分支: `git branch`
* 创建并切换到分支: `git checkout -b <branch>`
* 创建分支: `git branch <name>`
* 切换到分支: `git checkout <branch>`
* 合并当前分支到某分支: `git merge <branch>`
* 禁用Fast-forward合并分支(保留分支信息): `git merge --no-ff -m "<messsage>" <branch>`
* 储存当前未完成的更改: `git stush`
* 查看当前储存的内容: `git stush list`
* 恢复储存的更改: `git stash apply`
* 删除储存的更改: `git stash drop`
* 恢复并删除储存的更改: `git stash pop`
* 强制删除未合并的分支: `git branch -D <branch>`
* 查看远程库信息: `git remote -v`
* 创建与远程分支对应的分支: `git checkout -b <branch> <repo>/<branch>`
* 关联本地已有分支与远程分支: `git branch --set-upstream <branch> <repo>/<branch>`
* 从远程抓取分支: `git pull`
* 为当前分支的最新提交打标签: `git tag <tagname>`
* 查看所有标签: `git tag`
* 为当前分支的某一提交打标签: `git tag <tagname> <commit-id>`
* 查看某一标签的信息: `git show <tagname>`
* 创建带有说明的标签: `git tag -a <tagname> -m "<message>" <commit-id>`
* 删除本地标签: `git tag -d <tagname>`
* 推送某个标签到远程: `git push <repo> <tagname>`
* 推送全部未推送到远程的标签: `git push <repo> --tags`
* 删除远程标签(需要先删除本地标签): `git push <repo> :refs/tags/<tagname>`
* 让git显示颜色: `git config --global color.ui true`
* 配置别名: `git config --global alias.<alias> <command>`
* 忽略特殊文件: [链接](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/0013758404317281e54b6f5375640abbb11e67be4cd49e0000)
* 廖雪峰的git教程: [链接](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
* pdf版git-cheatsheet(国外网友制作, 英文): [链接](http://pan.baidu.com/s/1jGxjQL4#path=%252Fpub%252Fgit)
