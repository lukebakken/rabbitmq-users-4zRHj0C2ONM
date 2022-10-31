# rabbitmq-users-4zRHj0C2ONM
https://groups.google.com/g/rabbitmq-users/c/4zRHj0C2ONM

# Creating expired certs for `rmq1`

```
cd tls-gen/basic
make clean
faketime 'last Friday 5 pm' make CN=rmq1 DAYS_OF_VALIDITY=rmq1
```
