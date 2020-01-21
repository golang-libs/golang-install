Golang-Install
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
$ curl https://raw.githubusercontent.com/skiy/golang-install/master/install.sh | bash
```

#### Custom version   
- **MY_DIY_GO_VERSION** is a custom golang version, such as： ```1.12.8```
- **MY_DIY_GO_PATH** is a custom gopath, such as： ```/home/myhome/go```

```sh
$ curl -SL https://raw.githubusercontent.com/skiy/golang-install/master/install.sh | bash /dev/stdin -v MY_DIY_GO_VERSION -d MY_DIY_GO_PATH
```

### Offline
Save the script as a file name **install.sh**    

```sh
# default install
$ sh install.sh   
   
# customize  
$ sh install.sh -v 1.12.8 -d /home/myhome/go 
```
  
When you add executable permissions, you can customize the version and gopath.   
```sh
# add executable
$ chmod +x install.sh

# default install
$ ./install.sh

# customize 
$ ./install.sh -v 1.12.8 -d /home/myhome/go
```

**Usage**    
./install.sh -h
```
Go install

Usage: ./install.sh [-h] [-v version] [-d gopath]

Options:
  -h            : this help
  -v            : set go version (default: latest version)
  -d            : set go path (default: ~/.go/path)
```

## Author
Author: Skiychan   
Email : dev@skiy.net   
Link  : https://www.skiy.net 

## License

This project is licensed under the [MIT license](https://github.com/totoval/totoval/blob/master/LICENSE).