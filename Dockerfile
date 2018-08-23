FROM openjdk:10-jdk-slim

RUN mkdir /usr/local/vamp
ADD . /usr/local/vamp

CMD ["/usr/local/vamp/vamp"]
