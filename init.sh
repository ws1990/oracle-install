#!/bin/bash
sql_file="init.sql"
oracle_sid='WS'
tablespace_dir="/opt/oracle/oradata/${oracle_sid}/tablespaces"
datafile_dir="/opt/oracle/oradata/${oracle_sid}/datafile"
db_name_array=('ws_test')
db_user_array=('ws_test_user')
db_password="ws_1234"

init_sql() {
  for((i=0;i<${#db_name_array[@]};i++))
  do
    db_name=${db_name_array[$i]}
    db_user=${db_user_array[$i]}
    # 创建pdb和用户
    sql="alter session set container=cdb\$root;\ncreate pluggable database ${db_name} admin user ${db_user} identified by ${db_password}  file_name_convert = ('/opt/oracle/oradata/${oracle_sid}/pdbseed/', '${datafile_dir}/${db_name}/');\nalter pluggable database ${db_name} open read write;\nalter session set container = ${db_name};\ncreate tablespace ${db_name} datafile '${tablespace_dir}/${db_name}.dbf' size 200m autoextend on next 100m;\nalter user ${db_user} default tablespace ${db_name};\n"
    echo -e $sql >> ${sql_file}

    # 给用户赋予权限
    sql="grant dba to ${db_user};\ngrant connect,resource to ${db_user};\ngrant create any sequence to ${db_user};\ngrant create any table to ${db_user};\ngrant delete any table to ${db_user};\ngrant insert any table to ${db_user};\ngrant select any table to ${db_user};\ngrant unlimited tablespace to ${db_user};\ngrant execute any procedure to ${db_user};\ngrant update any table to ${db_user};\ngrant create any view to ${db_user};\n"
    echo -e $sql >> ${sql_file}
  done
  echo "exit;" >> ${sql_file}
}


if [ ! -e ${sql_file}  ];then
  touch ${sql_file}
else 
  sed -i 'd' ${sql_file}
fi

if [ ! -d ${tablespace_dir} ];then
  mkdir -p ${tablespace_dir}
fi

if [ ! -d ${datafile_dir} ];then
  mkdir -p ${datafile_dir}
fi


echo "创建初始化sql脚本"
init_sql
echo "连接数据库并执行脚本"
sqlplus / as sysdba @${sql_file}
