# Project Vamp DC/OS Docker
DC/OS에서 동작하는 vamp를 도커로 패키징하는 저장소입니다.

### Prerequisites

#### build vamp core
vamp core 빌드후 libs에 있는 결과물을 bin 폴더로 옮겨주세요.
```
sbt clean test publish-local
sbt 'project bootstrap' pack
cp {{vamp core directory}}/bootstrap/target/pack/lib/* bin
```

#### build vamp-ui
UI 빌드후에 dist 폴더에 있는 결과물을을 ui 폴더로 옮겨주세요.
```
cd {{ vamp-ui directory }}
make build
cp -r {{ vamp-ui directory }}/dist ui
```

### configuration
설정파일을 자신의 환경에 맞게 수정 해주세요.
conf/application.conf
```
vamp_url = "http://10.20.0.100:8080"
vamp_url = ${?VAMP_URL}
zookeeper_servers = "zk-1.zk:2181"
zookeeper_servers = ${?VAMP_ZOOKEEPER_SERVERS}
zookeeper_connect_timeout = 5000
zookeeper_session_timeout = 5000
db_url          = ""
db_url          = ${?VAMP_DB_URL}
db_user         = ""
db_user         = ${?VAMP_DB_USER}
db_password     = ""
db_password     = ${?VAMP_DB_PASSWORD}

vamp {
  namespace = "services"
  bootstrap.timeout = 3 seconds

  container-driver {
    type = "marathon"
    network = "bridge"
    label-namespace = "io.vamp"
    response-timeout = 30 seconds # timeout for container operations
  }

  container-driver {
    mesos.url = "http://leader.mesos:5050"
    marathon {
      user = ""
      password = ""
      token = ""
      url = "http://marathon.mesos:8080"
      sse = true
      namespace-constraint = []
      cache {
        read-time-to-live = 30 seconds  # get requests can't be sent to Marathon more often than this, unless cache entries are invalidated
        write-time-to-live = 30 seconds # post/put/delete requests can't be sent to Marathon more often than this, unless cache entries are invalidated
        failure-time-to-live = 30 seconds # ttl in case of a failure (read/write)
      }
    }
  }
  gateway-driver {
    host = "" # vamg gateway agent host
    response-timeout = 30 seconds # timeout for gateway operations
    marshallers = [
      {
        type = "haproxy"
        name = "1.8"
        template {
          file = "" # if specified it will override the resource template
          resource = "/io/vamp/gateway_driver/haproxy/template.twig" # it can be empty
        }
      }
    ]
  }

  persistence {
    response-timeout = 5 seconds #
    database {
      type: "mysql"
      sql {
        url = ${db_url}
        user = ${db_user}
        password = ${db_password}
        delay = ${sql_delay}
        delay = 3s
        table = "Artifacts"
        synchronization.period = 0s
      }
      file {
        directory = ""
      }
    }
    key-value-store {
      type = "zookeeper"
      zookeeper {
        servers = ${zookeeper_servers}
        session-timeout = ${zookeeper_session_timeout}
        connect-timeout = ${zookeeper_connect_timeout}
      }
    }
  }

  pulse {
    type = "no-store" # no-store
    response-timeout = 30 seconds # timeout for pulse operations
  }

  workflow-driver {
    type = "marathon" # it's possible to combine (csv): 'type_x,type_y'
    response-timeout = 30 seconds # timeout for container operations
    workflow {
      deployables = []
      scale {         # default scale, if not specified in workflow
        instances = 1
        cpu = 0.1
        memory = 64MB
      }
    }
  }
  http-api {
    port = 8080
    interface = 0.0.0.0
    # ssl = true
    # certificate = /absolute/path/to/certificate.p12
    response-timeout = 10 seconds # HTTP response timeout
    strip-path-segments = 0
    sse.keep-alive-timeout = 15 seconds # timeout after an empty comment (":\n") will be sent in order keep connection alive
    websocket.stream-limit = 100
    ui {
      directory = "/usr/local/vamp/ui"
      index = "/usr/local/vamp/ui/index.html"
    }
  }
}

akka {

  loglevel = "INFO"
  log-dead-letters = 0
  log-config-on-start = off
  log-dead-letters-during-shutdown = off
  loggers = ["akka.event.slf4j.Slf4jLogger"]
  event-handlers = ["akka.event.slf4j.Slf4jEventHandler"]

  actor.default-mailbox.mailbox-type = "akka.dispatch.SingleConsumerOnlyUnboundedMailbox"

  default-dispatcher.fork-join-executor.pool-size-max = 32
  jvm-exit-on-fatal-error = true

  http.server.server-header = ""
}
```
vamp gateway agent 실행 예제

```
docker run --name vamp-gateway-agent-dev -d -p 80:80 -p 9090:9090 -p 18007:18007 -p 18008:18008 -p 18006:18006 -p 18005:18005 -p 22701:22701 -p 12701:12701 -p 22339:22339 -p 21339:21339 -v /data0/vamp/haproxy/log:/var/log -v /etc/localtime:/etc/localtime -e VAMP_ELASTICSEARCH_URL=http://192.168.190.51:9200 -e VAMP_KEY_VALUE_STORE_CONNECTION=192.168.190.51:2181 -e VAMP_KEY_VALUE_STORE_PATH=/vamp/services/gateways/haproxy/1.8/configuration -e VAMP_KEY_VALUE_STORE_TYPE=zookeeper --restart always --privileged --ulimit nofile=1000593:1000593 --hostname=`hostname` docker.toss.bz/vamp-gateway-agent:080813
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
