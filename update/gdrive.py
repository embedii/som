import io
import subprocess
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from googleapiclient.http import MediaIoBaseDownload

#ext = {"application/vnd.google-apps.document":{"type":"text/plain","ext":"txt"}}

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/drive"]
driveid = '1YaBmJqOTibixRAmMFZTINaweYGzXAk32'
mpath = subprocess.getoutput('find ~/ -type d -name "myai"')
fpath = subprocess.getoutput('find ~/ -type d -name "Workspace" | grep -Po ".*[^Workspace]"')
creds = service_account.Credentials.from_service_account_file(f'{mpath}/gdrive/service_account.json', scopes=SCOPES)
 
def list(id):
 sv = build('drive', 'v3', credentials=creds)
 result = sv.files().list(q="'"+ id +"' in parents", fields="nextPageToken, files(id, name, mimeType, modifiedTime, fileExtension)").execute()
 drive = result.get('files', [])
 obj = []
 for i in drive:
  fext = "unknow"
  if "fileExtension" in i:
   fext = i["fileExtension"]
  ob = {"fileExtension": fext, "mimeType": i["mimeType"], "id": i["id"], "name": i["name"], "modifiedTime": i["modifiedTime"]}
  obj.append(ob)
 print(obj)

def update(dire,fname,fid):
 pat = fpath + dire 
 media = MediaFileUpload(pat)
 sv = build('drive','v3',credentials=creds)
# result = sv.files().update(fileId='1AKE0ieVOoB4QnOdRDyFyyVH9qTnJ2WjO').execute()
 file_data = {'name':fname,'parents':[fid]}
 result = sv.files().create(body=file_data, media_body=media, fields='id').execute()
# drive = result.get('id')

def download(mtype,ext,file_id,fname,dire):
 sv = build('drive','v3',credentials=creds) 
 ff =  fname.split(".")
 fname = ff[0]

 #ttype = mtype
 #extt = ext
 if mtype == "application/vnd.google-apps.document":
  mtype = "text/plain"
  ext = "txt"
  pat = fpath + dire + fname + "." + ext
  file = io.BytesIO()
  request = sv.files().export_media(fileId=file_id, mimeType=mtype)
  downloader = MediaIoBaseDownload(file, request)
  done = False
  while done is False:
   status, done = downloader.next_chunk()
   print(f"Complete {int(status.progress() * 100)}%")
  fh = open(pat,"wb")
  fh.write(file.getvalue())
  fh.close() 
 else:
  pat = fpath + dire + fname + "." + ext
  file = io.FileIO(pat,"wb")
  request = sv.files().get_media(fileId=file_id)
  downloader = MediaIoBaseDownload(file, request)
  done = False
  while done is False:
   status, done = downloader.next_chunk()
   print(f"Complete {int(status.progress() * 100)}%")
 

#def main():
# result = sv.about().get(fields="kind, user").execute()
# drive = result
# print(drive)
# if not drive:
#  print('No files found.')
#  return

# if __name__ == "__main__":
#  main()
