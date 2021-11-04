Golang Install
------
The latest version of the golang is installed.   
- Support **Linux / MacOS / FreeBSD**
- Support custom **version**  
- Support custom **GOPATH** 
   
English | [简体中文](./README_CN.md)

#### Notice
- By default, the latest version of **go version** is installed, and the **GOPATH** directory is ```~/.go/path```

## Installation
### Online
#### Default install 
```sh
$ curl -fsL https://raw.githubusercontent.com/golang-libs/golang-install/main/install.sh | bash
```

### Offline
Save the script as a file name **install.sh**    

```sh
# default install
$ bash install.sh   
```
  
When you add executable permissions, you can customize the version and gopath.   
```sh
# add executable
$ chmod +x install.sh

# default install
$ ./install.sh

## License

This project is licensed under the [MIT license](./LICENSE).
