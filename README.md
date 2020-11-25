This is the code for two things:
- Have a basic arch linux image that can manage repos
- Build my own repo based on the content of my pkglist

Your image
==========

For the first bit, you can build your own image by
forking this repo, for example if you want to have
extra base repositories or something like that.

My image
========

If you only want to build your own repo with my image,
it's simple, use a volume mount to expose your package
list (don't change what's after the `:`):

`docker run -v /_path_to_your_pkglist:/home/builder/arch-repo-builder/pkglist --name archlinux-repo evrardjp/arch-packages:latest`

The resulting repo will be in the folder
`/home/builder/arch-repo/` in the container.
Don't change it. If you change it, also edit your config.
Just fork the project if that's what you want to do.
If you want to export the results of your build somewhere,
either extract the content of the container, or simply
bind mount the `/home/builder/arch-repo/` folder before
running the container:

`docker run -v "$(pwd)"/myrepo/:/home/builder/arch-repo/ --name archlinux-repo evrardjp/arch-packages:latest`

This is what I run for my case:

```
docker run -it -v "$(pwd)"/myrepo/:/home/builder/arch-repo/ -v "$(pwd)"/pkglist:/home/builder/arch-repo-builder/pkglist --name archlinux-repo evrardjp/arch-packages:latest
```
