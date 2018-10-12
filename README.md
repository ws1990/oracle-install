# 1. 概述
本文档为了方便命令展示，采用markdown语法，建议使用专门编辑器进行查看（或由工具转换成html）；数据库安装采用docker运行，在需要快速搭建开发和测试环境的时候，可以采用该方案；

# 2. docker安装
docker安装可以查看[阿里云镜像](https://opsx.alibaba.com/mirror)的[帮助手册](https://yq.aliyun.com/articles/110806)，大体步骤如下：
```shell
# step 1: 安装必要的一些系统工具
yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装 Docker-CE
yum makecache fast
yum -y install docker-ce
# Step 4: 开启Docker服务
systemctl start docker
# Setp 5: 开机启动Docker
systemctl enable docker
```
# 3. Oracle数据库安装运行
## 3.1 数据库镜像
数据库镜像已经上传阿里云镜像仓库，可以直接pull；当然也可以根据官方的手册，自己生成镜像。
```shell
# 1. pull镜像
docker pull registry.cn-hangzhou.aliyuncs.com/wangsong/oracle-12c:12.2.0.1-ee
# 2. tag镜像
docker tag registry.cn-hangzhou.aliyuncs.com/wangsong/oracle-12c:12.2.0.1-ee oracle/database:12.2.0.1-ee
```
## 3.2 数据库运行
```shell
# 1. 创建容器持久数据目录
mkdir /home/oracle
mkdir /home/oracle/oradata
mkdir /home/oracle/scripts
chown -R 54321:54321 /home/oracle
# 2. 上传init.sh脚本到/home/oracle/scripts目录并修改拥有者
chown /home/oracle/scripts/init.sh
# 3. 启动容器（密码根据实际情况进行修改，不建议使用简单的如oracle之类的，本例中就是一个典型的反面案例）
docker run -d \
--name oracle \
-p 5500:5500 -p 1521:1521 \
-v /etc/timezone:/etc/timezone \
-v /etc/localtime:/etc/localtime \
-v /home/oracle/oradata:/opt/oracle/oradata \
-v /home/oracle/scripts:/opt/oracle/scripts/setup \
-e ORACLE_SID=weas -e ORACLE_PDB=weaspdb -e ORACLE_PWD=oracle \
oracle/database:12.2.0.1-ee
```

## 3.3 导入导出
将dump.sh和imp.sh上传到服务器，参考命令如下(在执行脚本之前，请先检查脚本中的username，password，model等参数是否正确)：
```shell
# 1. 导出
./dump.sh /home/oracle/dump/20181010
# 2. 导入
./imp.sh /home/oracle/dump/20181010
```

# 4. 参考
1. [oracle官方镜像](https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance)
