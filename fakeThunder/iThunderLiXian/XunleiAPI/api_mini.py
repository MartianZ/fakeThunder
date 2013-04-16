#author: MartianZ <fzyadmin@gmail.com>

import socket
import random
import requests
from hashlib import md5
from lixian_api import LiXianAPI, determin_url_type
import tornado.ioloop
import tornado.web
from time import time
from datetime import datetime
import json
import os

def hex_md5(string):
    return md5(string).hexdigest()

def thunder_login(username, password, secure, hashstr):
	if not secure:
		hash = hex_md5(username + password + username)
	else:
		hash = hashstr

	lixianAPI = LiXianAPI()
	
	try:
		if secure:
			isLogin = lixianAPI.secure_login(username, password)
		else:
			isLogin = lixianAPI.login(username, password)
	except:
		isLogin = False
	
	if isLogin:
		print 'USER LOGIN SUCCESS: ' + username
		try:
			if not secure:
				#save user info
				print pyfile_dir
				
				f = open(pyfile_dir + '/.fakeThunder_' + hash +'.txt', 'w')
				f.truncate(0)
				f.write(username + '\n' + hex_md5(hex_md5(password)))
				f.close()
				
				pass
		except:
			pass
				
		lixianAPIs[hash] = lixianAPI
		lixianAPIs_login_status[hash] = True
		lixianAPIs_last_update_time[hash] = time()
		
		return True
	else:
		print 'USER LOGIN FAIL: ' + username
		return False

def check_login(hash):
	isLogin = False
		
	if lixianAPIs.get(hash):
		lixianAPI = lixianAPIs.get(hash)
		if time() - lixianAPIs_last_update_time.get(hash) < 300:
			isLogin = lixianAPIs_login_status.get(hash)
		else:
			isLogin = lixianAPI.check_login()
			lixianAPIs_login_status[hash] = isLogin
			lixianAPIs_last_update_time[hash] = time()
			
	if not isLogin:
		f = open(pyfile_dir + '/.fakeThunder_' + hash + '.txt', 'r')
		username = f.readline()[0:-1]
		password = f.readline()
		f.close()
		if username and password:
			isLogin = thunder_login(username, password, True, hash)

	return isLogin

class InitialHandler(tornado.web.RequestHandler):
	def get(self, username, password):
		hash = hex_md5(username + password + username)
		
		if thunder_login(username, password, False, ''):
			self.write(hash)
		else:
			self.write('Fail')


class GetTaskListHandler(tornado.web.RequestHandler):
	def get(self, hash, limit, st):
	
		isLogin = check_login(hash)
		if not isLogin:
			self.write("Fail")
			self.finish()
			return
			
		lixianAPI = lixianAPIs.get(hash)
		
		tasklist = lixianAPI.get_task_list(int(limit), 4)
		tasklist_json = json.dumps(tasklist)
		self.write(tasklist_json)

class DeleteTask(tornado.web.RequestHandler):
    def get(self, hash, task_id):

        isLogin = check_login(hash)
        if not isLogin:
            self.write("Fail")
            self.finish()
            return

        lixianAPI = lixianAPIs.get(hash)

        result = lixianAPI.delete_task([task_id])
        if (result):
            self.write("Success")
        else:
            self.write("Fail")




class AddTaskHandler(tornado.web.RequestHandler):
	def get(self, hash, url):
		self.write("POST HERE")
		
	def post(self):
		hash = self.get_argument("hash")
		url = self.get_argument("url")
		isLogin = check_login(hash)
		if not isLogin:
			self.write("Fail")
			self.finish()
			return
			
		lixianAPI = lixianAPIs.get(hash)
		if lixianAPI.add(url):
			self.write("Success")
		else:
			self.write("Fail")
			
class GetTorrentFileListHandler(tornado.web.RequestHandler):
	def get(self, hash, url):
		self.write("POST HERE")

	def post(self):
		hash = self.get_argument("hash")
		url = self.get_argument("url")

		isLogin = check_login(hash)
		if not isLogin:
			self.write("Fail")
			self.finish()
			return

		lixianAPI = lixianAPIs.get(hash)
		filelist = lixianAPI.torrent_upload_by_path(url)
		self.write(json.dumps(filelist))

class AddBTTaskHandler(tornado.web.RequestHandler):
	def get(self, hash, url):
		self.write("POST HERE")

	def post(self):
		hash = self.get_argument("hash")
		info = json.loads(self.get_argument("info"))
		url = self.get_argument("url")
		isLogin = check_login(hash)
		if not isLogin:
			self.write("Fail")
			self.finish()
			return
		lixianAPI = lixianAPIs.get(hash)
		if lixianAPI.add_bt_task_with_dict(url,info):
			self.write("Success")
		else:
			self.write("Fail")


class GetBTListHandler(tornado.web.RequestHandler):
	def get(self, hash, tid, cid):
		isLogin = check_login(hash)
		if not isLogin:
			self.write("Fail")
			self.finish()
			return
			
		lixianAPI = lixianAPIs.get(hash)
		result = lixianAPI.get_bt_list(int(tid), cid)
		self.write(json.dumps(result))
		
class GetCookieHandler(tornado.web.RequestHandler):
	def get(self, hash):
		isLogin = check_login(hash)
		if not isLogin:
			self.write("Fail")
			self.finish()
			return
			
		lixianAPI = lixianAPIs.get(hash)
		self.write("gdriveid=" + lixianAPI.gdriveid + ";")

class VodGetPlayUrl(tornado.web.RequestHandler):
	def get(self):
		self.write("POST HERE")
		
	def post(self):
		print self.request.arguments
		hash = self.get_argument("hash")
		url = self.get_argument("url")
		
		isLogin = check_login(hash)
		if not isLogin:
			self.write("Fail")
			self.finish()
			return
		
		print url
		lixianAPI = lixianAPIs.get(hash)
		self.write(lixianAPI.cloud_play_get_url(url))
		
		
class ZeroHandler(tornado.web.RequestHandler):
	def get(self, hash):
		self.write("Mitsukatta~~ToT")



application = tornado.web.Application([
	(r'/initial/(.*)/(.*)', InitialHandler),  #API 1
	(r'/([A-Za-z0-9]{32})/get_task_list/([0-9]*)/([0-9]*)', GetTaskListHandler), #API 2
	(r'/add_task', AddTaskHandler), #API 3
	(r'/([A-Za-z0-9]{32})/get_bt_list/(.*)/(.*)', GetBTListHandler), #API 4 TID CID
	(r'/get_torrent_file_list', GetTorrentFileListHandler),
	(r'/add_bt_task', AddBTTaskHandler),
	(r'/([A-Za-z0-9]{32})/get_cookie',  GetCookieHandler),
	(r'/vod_get_play_url', VodGetPlayUrl),
    (r'/DeleteTask/(.*)/(.*)', DeleteTask),
	(r'(.*)', ZeroHandler),  #API Zero

])


if __name__ == "__main__":
	
	#pyfile_dir = os.path.split(os.path.realpath(__file__))[0]
	pyfile_dir = os.path.expanduser("~")
	lixianAPIs = {}
	lixianAPIs_login_status = {}
	lixianAPIs_last_update_time = {}
	
	
	application.listen(9999)
	print "The Thunder API Sutato!"
	
	tornado.ioloop.IOLoop.instance().start()