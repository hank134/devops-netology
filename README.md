1. $ git show aefea
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
2. git show 85024d3
tag: v0.12.23
3. git show b8d720^ 
git show b8d720^2   
2 родителя
4. git log v0.12.23..v0.12.24 --oneline
* b14b74c49 [Website] vmc provider links
* 3f235065b Update CHANGELOG.md
* 6ae64e247 registry: Fix panic when server is unreachable
* 5c619ca1b website: Remove links to the getting started guide's old location
* 06275647e Update CHANGELOG.md
* d5f9411f5 command: Fix bug when using terraform login on Windows
* 4b6d06cc5 Update CHANGELOG.md
* dd01a3507 Update CHANGELOG.md
* 225466bc3 Cleanup after v0.12.23 release
5. $ git log -S'func providerSource(' --oneline
8c928e835 main: Consult local directories as potential mirrors of providers
6. $ git log -S'globalPluginDirs' --oneline
35a058fb3 main: configure credentials from the CLI config file
c0b176109 prevent log output during init
8364383c3 Push plugin discovery down into command package
7. $ git log -S 'synchronizedWriters' --pretty=format:"%h, %an"
bdfea50cc, James Bardin
fd4f7eb0b, James Bardin
5ac311e2a, Martin Atkins 
Первый коммит с функцией synchronizedWriters сделал Martin Atkins


