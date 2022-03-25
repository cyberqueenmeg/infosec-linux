#!/usr/bin/env python
# coding: utf-8
# Heavily based on https://github.com/jcnaud/python-linux-iso/blob/master/linuxiso/download.py with edits for InfoSec Linux. Thanks to @jcnaud for providing this under the BSD-2 License, listed below!
# This file is a Python class that allows the download of ISO files for the InfoSec Linux virtual machine automation.

'''
Updated Notice to reflect Creator and Year:

Copyright (c) 2022, Megan Howell
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Original Notice:

Copyright (c) 2011, Jean-charles NAUD
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'''

import os
import sys

class Download(object):
    """
    Class manage download and verify iso.
    :param dict conf: Configuration
    You need to provide configuration with all info of iso managed.
    The typical use is:
     - chose a config that containt all info about iso
     - **list** iso managed
     - get the **status** of one or all iso (**status_all**)
     - do operation on iso like **download**, **download_all**,
       **remove** or **remove_all**
    >>> download = Download(conf)
    >>> download.list()
    >>> download.download("debian-9.6.0-strech-amd64-netinst.iso")
    """

    def __init__(self, conf=None):
        self.conf = conf

    def list(self):
      download.list()
        [
            "https://cdimage.kali.org/kali-2022.1/kali-linux-2022.1-installer-amd64.iso",
            
        ]
        return sorted(list(self.conf['download'].keys()))

    def _check_url(self, url):
        """ Check if url exist
        :return: True if url exist, else False
        :rtype: bool
        """
        try:
            reponse = requests.head(url, allow_redirects=True)
            if reponse.status_code == 200:
                return True
        except Exception as e:
            logging.debug(e)

        return False

    def download(self, iso):
        """Download one iso
        :param str iso: Name of iso used
        >>> download.download("iso_name.iso")
        """
        url_iso = self.conf['download'][iso]['url_iso']
        dir_input = self.conf['general']['dir_input']
        file_iso = dir_input+os.sep+iso

        if not os.path.isdir(dir_input):
            os.makedirs(dir_input)

        if not os.path.exists(file_iso):
            logging.info("Download : "+file_iso)
            # urllib.request.urlretrieve(url_iso, file_iso)
            rep = requests.get(url_iso, stream=True, allow_redirects=True)
            total_length = int(rep.headers.get('content-length'))

            with open(file_iso, 'wb') as fd:
                #for chunk in rep.iter_content(chunk_size=128):
                #    fd.write(chunk)

                for chunk in progress.bar(rep.iter_content(chunk_size=1024), expected_size=(total_length/1024) + 1):
                    if chunk:
                        fd.write(chunk)
                        fd.flush()
        else:
            logging.info("File exist, do nothing because already downloaded")
