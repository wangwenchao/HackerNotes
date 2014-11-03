##Git 

Git toturial and reference links

- offcial size: <http://git-scm.com/>
- <http://think-like-a-git.net/>
- git flow intro <http://nvie.com/posts/a-successful-git-branching-model/>
- gitflow <https://github.com/nvie/gitflow>
- <http://rogerdudler.github.io/git-guide/>
- <https://guides.github.com/>
- <http://python-guide.readthedocs.org/en/latest/>
- <http://marklodato.github.io/visual-git-guide/index-en.html>
- <http://jiongks.name/blog/a-successful-git-branching-model>
- <http://blog.jobbole.com/54184/>
- <http://blog.jobbole.com/50603/>
- <http://tom.preston-werner.com/2009/05/19/the-git-parable.html>

### git custom config
 
 ```shell
      git config --global user.name "<User Name>"
      git config --global user.email "<Email>"
      git config --global editor '< vim/macvim/mate>'
      git config --global alias.br 'branch'
      git config --global alias.co 'checkout'
      git config --global alias.ci 'commit'
      git config --global alias.st 'state'
      git config --global alias.unstage 'reset --hard --'
      git config --global alias.throw 'reset --hard HEAD'
      git config --global alias.throwh 'reset --hard HEAD^'
      git config --global alias.last  'log -l HEAD'
      git config --global alias.history 'log --graph --pretty --oneline'
      git config --global alias.merge 'merge --no-ff'
      
```

OR add the following into the ~/.gitconfig file is the git config file:

```
[alias]
  ci = commit -a -v
  cl = clone
  co = checkout
  st = status
  br = branch
  throw = reset --hard HEAD
  throwh = reset --hard HEAD^
  unstage = reset HEAD --
  last = log -l HEAD
  history = log --graph --pretty=oneline --abbrev-commit
  merge = merge --no-ff
  
[color]
  ui = true
```
