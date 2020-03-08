FROM debian:stretch-slim

LABEL description="大数据研发环境(Spark)"
LABEL version="3.5.3"
LABEL arch="x86_64"
LABEL build_time=
LABEL git_url1=https://github.com/iCivic/docker-jupyter-spark.git
LABEL git_url2=
LABEL git_branch=master
LABEL git_commit=

################
# dependencies #
################
COPY ./conf/sources.list /etc/apt/sources.list
COPY ./conf/pip.conf /etc/pip.conf
COPY ./conf/requirements.txt /mnt/idu/requirements.txt

RUN apt-get update && \
	dpkg-reconfigure -f noninteractive tzdata && \
	rm -rf /etc/localtime && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo "Asia/Shanghai" > /etc/timezone && \
	apt-get install -y --no-install-recommends graphviz

# OpenJDK
RUN apt-get update && \
    mkdir -p /usr/share/man/man1 && \
    apt-get install -y --no-install-recommends \     
	  python3 python3-pip python3-setuptools \
	  openjdk-8-jre-headless \
      ca-certificates-java && \
	rm -rf /var/lib/apt/* && \
    apt-get autoremove -y && \
    apt-get clean
	
# https://github.com/petronetto/docker-python-deep-learning
RUN pip3 --no-cache-dir install \
		#tensorflow==2.0.0.0 \
		tensorflow \
		tensorboard \
        matplotlib \
		ipykernel \
		jupyter \
		jupyterlab \
		pyyaml \
        pymkl \
        cffi \
        h5py \
        requests \
        pillow \
        graphviz \
        numpy \
        pandas \
        scipy \
        scikit-learn \
        seaborn \
        xgboost \
        keras \
		xlrd \
        mxnet-mkl && \
	jupyter nbextension enable --py widgetsnbextension && \
	jupyter kernelspec list && \
	jupyter lab --generate-config
	
# 拷贝中文字体
COPY ./SIMHEI.TTF /usr/local/lib/python3.6/site-packages/matplotlib/mpl-data/fonts/ttf/

# Spark
COPY ./spark-2.4.5-bin-hadoop2.7.tgz /tmp/spark-2.4.5-bin-hadoop2.7.tgz
COPY ./toree-0.3.0.tar.gz /tmp/toree-0.3.0.tar.gz
COPY ./jupyter_config.py /root/.jupyter/jupyter_notebook_config.py

ARG APACHE_SPARK_VERSION=2.4.5
ARG HADOOP_VERSION=2.7
ENV SPARK_NAME=spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}

ENV SPARK_DIR /opt/${SPARK_NAME}
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$SPARK_HOME/python/lib/pyspark.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info
	  
RUN pip3 --no-cache-dir install py4j		
RUN tar -xzf /tmp/${SPARK_NAME}.tgz -C /opt/ && \
    ln -s $SPARK_DIR $SPARK_HOME && \
    ln -s /usr/bin/pip3 /usr/bin/pip && \
    ln -s /usr/bin/python3 /usr/bin/python
	
# Toree
RUN pip3 install --no-cache-dir /tmp/toree-0.3.0.tar.gz && \
    jupyter toree install --spark_home=/usr/local/spark

EXPOSE 8888 4040

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root"]

COPY jupyter_config.py /root/.jupyter/jupyter_notebook_config.py
# COPY jupyter_config.py /root/.jupyter/jupyter_lab_config.py 

# Copy sample notebooks.
COPY notebooks /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh && \
    mkdir -p /tmp/tensorboard_logs

# Spark
EXPOSE 4040
# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

VOLUME ["/notebooks", \
        "/tmp/tensorflow_logs", \
		"/tmp/mnist"]

WORKDIR "/notebooks"

CMD ["/entrypoint.sh", "--allow-root"]

# docker build -t idu/jupyter-spark:2.4.5 .
# docker run --rm -it -p 6006:6006 -p 8888:8888 -p 4040:4040 -e PASSWORD=123456 --name=idu-spark-2.4.5 idu/jupyter-spark:2.4.5