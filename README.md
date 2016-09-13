# Docker Scala Sbt

This is an image with Scala and SBT based on Alpine.

Quite compact ~300mb.

## Usage

You can create an alias for the following command:
```
docker run -v `pwd`:`pwd` -w `pwd` -it vshulyak/scala_sbt sbt compile
```
