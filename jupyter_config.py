# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
import os
from IPython.lib import passwd

c.NotebookApp.ip = '*'
c.NotebookApp.port = 8888 # 指定端口，默认8888
c.NotebookApp.open_browser = False # 禁止自动打开浏览器
c.NotebookApp.allow_root = True # 以root身份运行
c.MultiKernelManager.default_kernel_name = 'python3'
c.NotebookApp.notebook_dir = '/notebooks'     # 指定工作目录
c.PAMAuthenticator.encoding = 'utf8'  #指定utf-8编码，解决读取中文路径或者文件乱码问题
c.InteractiveShell.ast_node_interactivity = "all"
 
# sets a password if PASSWORD is set in the environment
if 'PASSWORD' in os.environ:
    c.NotebookApp.password = passwd(os.environ['PASSWORD'])
    del os.environ['PASSWORD']
