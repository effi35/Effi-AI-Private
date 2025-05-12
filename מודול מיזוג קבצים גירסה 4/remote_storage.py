import os
import sys
import json
import logging
import tempfile
import traceback
import shutil
import time
from typing import Dict, List, Any, Optional, Tuple, Union, BinaryIO

class RemoteStorage:
    """מודול גישה לאחסון מרוחק למאחד קוד חכם Pro 2.0"""
    
    def __init__(self):
        self.initialized = False
        self.config = {}
        self.logger = logging.getLogger(__name__)
        self.connections = {}
        self.current_connection = None
        self.cache_dir = None
        self.cache_enabled = True
        self.cache_expiry_seconds = 3600  # ברירת מחדל: שעה
    
    def initialize(self, config: Dict[str, Any]) -> bool:
        """אתחול מנהל האחסון המרוחק"""
        self.config = config
        
        # הגדרת תיקיית מטמון
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.cache_dir = os.path.join(base_dir, "remote_cache")
        
        # יצירת תיקייה אם לא קיימת
        os.makedirs(self.cache_dir, exist_ok=True)
        
        # הגדרות מטמון
        self.cache_enabled = config.get("cache_enabled", True)
        self.cache_expiry_seconds = config.get("cache_expiry_seconds", 3600)
        
        # הגדרות זמן פסק
        self.timeout_seconds = config.get("timeout_seconds", 30)
        
        # בדיקת תלויות
        self._check_dependencies()
        
        # דגל אתחול
        self.initialized = True
        self.logger.info("מנהל האחסון המרוחק אותחל בהצלחה")
        
        return True
    
    def shutdown(self) -> bool:
        """כיבוי מנהל האחסון המרוחק"""
        try:
            # ניתוק כל החיבורים הפעילים
            for connection_id in list(self.connections.keys()):
                self.disconnect(connection_id)
            
            self.initialized = False
            self.logger.info("מנהל האחסון המרוחק כובה בהצלחה")
            return True
        except Exception as e:
            self.logger.error(f"שגיאה בכיבוי מנהל האחסון המרוחק: {str(e)}")
            return False
    
    def connect(self, storage_type: str, connection_params: Dict[str, Any]) -> str:
        """
        חיבור לאחסון מרוחק
        
        Args:
            storage_type: סוג האחסון (local/ssh/s3/ftp/webdav)
            connection_params: פרמטרי התחברות
            
        Returns:
            str: מזהה חיבור
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return ""
        
        try:
            # בדיקת תמיכה בסוג האחסון
            if storage_type not in ["local", "ssh", "s3", "ftp", "webdav", "smb", "nfs"]:
                self.logger.error(f"סוג אחסון לא נתמך: {storage_type}")
                return ""
            
            # יצירת מזהה חיבור
            connection_id = f"{storage_type}_{int(time.time())}_{id(connection_params)}"
            
            # הקמת החיבור לפי סוג האחסון
            connection = None
            
            if storage_type == "local":
                connection = self._connect_local(connection_params)
            elif storage_type == "ssh":
                connection = self._connect_ssh(connection_params)
            elif storage_type == "s3":
                connection = self._connect_s3(connection_params)
            elif storage_type == "ftp":
                connection = self._connect_ftp(connection_params)
            elif storage_type == "webdav":
                connection = self._connect_webdav(connection_params)
            elif storage_type == "smb":
                connection = self._connect_smb(connection_params)
            elif storage_type == "nfs":
                connection = self._connect_nfs(connection_params)
            
            if not connection:
                self.logger.error(f"חיבור לאחסון מסוג {storage_type} נכשל")
                return ""
            
            # שמירת החיבור
            self.connections[connection_id] = {
                "type": storage_type,
                "connection": connection,
                "params": connection_params,
                "created_at": time.time()
            }
            
            # עדכון החיבור הנוכחי
            self.current_connection = connection_id
            
            self.logger.info(f"חיבור לאחסון מרוחק מסוג {storage_type} בוצע בהצלחה (מזהה: {connection_id})")
            
            return connection_id
            
        except Exception as e:
            self.logger.error(f"שגיאה בחיבור לאחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            return ""
    
    def disconnect(self, connection_id: Optional[str] = None) -> bool:
        """
        ניתוק מאחסון מרוחק
        
        Args:
            connection_id: מזהה חיבור (אם לא צוין, ינותק החיבור הנוכחי)
            
        Returns:
            bool: האם הניתוק הצליח
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return False
        
        try:
            # החלטה איזה חיבור לנתק
            if not connection_id:
                connection_id = self.current_connection
            
            if not connection_id or connection_id not in self.connections:
                self.logger.error(f"חיבור {connection_id} לא נמצא")
                return False
            
            # שליפת פרטי החיבור
            connection_info = self.connections[connection_id]
            connection = connection_info["connection"]
            storage_type = connection_info["type"]
            
            # ניתוק לפי סוג האחסון
            success = False
            
            if storage_type == "local":
                success = True  # אין צורך בניתוק
            elif storage_type == "ssh":
                success = self._disconnect_ssh(connection)
            elif storage_type == "s3":
                success = True  # אין צורך בניתוק
            elif storage_type == "ftp":
                success = self._disconnect_ftp(connection)
            elif storage_type == "webdav":
                success = self._disconnect_webdav(connection)
            elif storage_type == "smb":
                success = self._disconnect_smb(connection)
            elif storage_type == "nfs":
                success = self._disconnect_nfs(connection)
            
            # מחיקת החיבור מהרשימה
            if success:
                del self.connections[connection_id]
                
                # אם זה היה החיבור הנוכחי, איפוס
                if self.current_connection == connection_id:
                    self.current_connection = None
                
                self.logger.info(f"ניתוק מאחסון מרוחק מסוג {storage_type} בוצע בהצלחה (מזהה: {connection_id})")
            
            return success
            
        except Exception as e:
            self.logger.error(f"שגיאה בניתוק מאחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            return False
    
    def list_files(self, path: str, connection_id: Optional[str] = None) -> Dict[str, Any]:
        """
        רשימת קבצים באחסון מרוחק
        
        Args:
            path: נתיב באחסון
            connection_id: מזהה חיבור (אם לא צוין, ישמש החיבור הנוכחי)
            
        Returns:
            Dict[str, Any]: רשימת קבצים ותיקיות
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return {"error": "מנהל האחסון המרוחק לא אותחל"}
        
        try:
            # החלטה איזה חיבור לשמש
            if not connection_id:
                connection_id = self.current_connection
            
            if not connection_id or connection_id not in self.connections:
                self.logger.error(f"חיבור {connection_id} לא נמצא")
                return {"error": f"חיבור {connection_id} לא נמצא"}
            
            # שליפת פרטי החיבור
            connection_info = self.connections[connection_id]
            connection = connection_info["connection"]
            storage_type = connection_info["type"]
            
            # בדיקה במטמון
            cache_key = f"{connection_id}_{path}"
            if self.cache_enabled:
                cached_result = self._get_from_cache(cache_key)
                if cached_result:
                    self.logger.debug(f"נמצא במטמון: רשימת קבצים עבור {path}")
                    return cached_result
            
            # רשימת קבצים לפי סוג האחסון
            result = None
            
            if storage_type == "local":
                result = self._list_files_local(connection, path)
            elif storage_type == "ssh":
                result = self._list_files_ssh(connection, path)
            elif storage_type == "s3":
                result = self._list_files_s3(connection, path)
            elif storage_type == "ftp":
                result = self._list_files_ftp(connection, path)
            elif storage_type == "webdav":
                result = self._list_files_webdav(connection, path)
            elif storage_type == "smb":
                result = self._list_files_smb(connection, path)
            elif storage_type == "nfs":
                result = self._list_files_nfs(connection, path)
            
            if not result:
                self.logger.error(f"רשימת קבצים בנתיב {path} נכשלה")
                return {"error": f"רשימת קבצים בנתיב {path} נכשלה"}
            
            # שמירה במטמון
            if self.cache_enabled:
                self._save_to_cache(cache_key, result)
            
            self.logger.info(f"רשימת קבצים בנתיב {path} הושלמה בהצלחה")
            
            return result
            
        except Exception as e:
            self.logger.error(f"שגיאה ברשימת קבצים באחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "error": str(e),
                "path": path,
                "traceback": traceback.format_exc()
            }
    
    def download_file(self, remote_path: str, local_path: str, connection_id: Optional[str] = None) -> Dict[str, Any]:
        """
        הורדת קובץ מאחסון מרוחק
        
        Args:
            remote_path: נתיב הקובץ באחסון המרוחק
            local_path: נתיב מקומי לשמירת הקובץ
            connection_id: מזהה חיבור (אם לא צוין, ישמש החיבור הנוכחי)
            
        Returns:
            Dict[str, Any]: תוצאות ההורדה
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return {"error": "מנהל האחסון המרוחק לא אותחל"}
        
        try:
            # החלטה איזה חיבור לשמש
            if not connection_id:
                connection_id = self.current_connection
            
            if not connection_id or connection_id not in self.connections:
                self.logger.error(f"חיבור {connection_id} לא נמצא")
                return {"error": f"חיבור {connection_id} לא נמצא"}
            
            # שליפת פרטי החיבור
            connection_info = self.connections[connection_id]
            connection = connection_info["connection"]
            storage_type = connection_info["type"]
            
            # בדיקה במטמון
            cache_key = f"{connection_id}_{remote_path}_content"
            cached_file = None
            
            if self.cache_enabled:
                cached_file = self._get_cached_file(cache_key)
                if cached_file:
                    # העתקת הקובץ מהמטמון
                    try:
                        shutil.copy2(cached_file, local_path)
                        self.logger.debug(f"נמצא במטמון: קובץ {remote_path}")
                        
                        return {
                            "status": "success",
                            "source": "cache",
                            "remote_path": remote_path,
                            "local_path": local_path,
                            "size": os.path.getsize(local_path),
                            "connection_id": connection_id
                        }
                    except Exception as e:
                        self.logger.warning(f"שגיאה בהעתקה מהמטמון: {str(e)}")
                        # נמשיך להורדה רגילה
            
            # הורדת הקובץ לפי סוג האחסון
            result = None
            
            if storage_type == "local":
                result = self._download_file_local(connection, remote_path, local_path)
            elif storage_type == "ssh":
                result = self._download_file_ssh(connection, remote_path, local_path)
            elif storage_type == "s3":
                result = self._download_file_s3(connection, remote_path, local_path)
            elif storage_type == "ftp":
                result = self._download_file_ftp(connection, remote_path, local_path)
            elif storage_type == "webdav":
                result = self._download_file_webdav(connection, remote_path, local_path)
            elif storage_type == "smb":
                result = self._download_file_smb(connection, remote_path, local_path)
            elif storage_type == "nfs":
                result = self._download_file_nfs(connection, remote_path, local_path)
            
            if not result or result.get("status") != "success":
                self.logger.error(f"הורדת קובץ מנתיב {remote_path} נכשלה")
                return result or {"error": f"הורדת קובץ מנתיב {remote_path} נכשלה"}
            
            # שמירה במטמון
            if self.cache_enabled and os.path.exists(local_path):
                self._cache_file(cache_key, local_path)
            
            self.logger.info(f"הורדת קובץ מנתיב {remote_path} הושלמה בהצלחה")
            
            return result
            
        except Exception as e:
            self.logger.error(f"שגיאה בהורדת קובץ מאחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "remote_path": remote_path,
                "local_path": local_path,
                "traceback": traceback.format_exc()
            }
    
    def upload_file(self, local_path: str, remote_path: str, connection_id: Optional[str] = None) -> Dict[str, Any]:
        """
        העלאת קובץ לאחסון מרוחק
        
        Args:
            local_path: נתיב הקובץ המקומי
            remote_path: נתיב באחסון המרוחק
            connection_id: מזהה חיבור (אם לא צוין, ישמש החיבור הנוכחי)
            
        Returns:
            Dict[str, Any]: תוצאות ההעלאה
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return {"status": "error", "error": "מנהל האחסון המרוחק לא אותחל"}
        
        try:
            # בדיקת קיום הקובץ המקומי
            if not os.path.isfile(local_path):
                self.logger.error(f"קובץ מקומי {local_path} לא קיים")
                return {
                    "status": "error",
                    "error": f"קובץ מקומי {local_path} לא קיים",
                    "local_path": local_path,
                    "remote_path": remote_path
                }
            
            # החלטה איזה חיבור לשמש
            if not connection_id:
                connection_id = self.current_connection
            
            if not connection_id or connection_id not in self.connections:
                self.logger.error(f"חיבור {connection_id} לא נמצא")
                return {
                    "status": "error",
                    "error": f"חיבור {connection_id} לא נמצא",
                    "local_path": local_path,
                    "remote_path": remote_path
                }
            
            # שליפת פרטי החיבור
            connection_info = self.connections[connection_id]
            connection = connection_info["connection"]
            storage_type = connection_info["type"]
            
            # העלאת הקובץ לפי סוג האחסון
            result = None
            
            if storage_type == "local":
                result = self._upload_file_local(connection, local_path, remote_path)
            elif storage_type == "ssh":
                result = self._upload_file_ssh(connection, local_path, remote_path)
            elif storage_type == "s3":
                result = self._upload_file_s3(connection, local_path, remote_path)
            elif storage_type == "ftp":
                result = self._upload_file_ftp(connection, local_path, remote_path)
            elif storage_type == "webdav":
                result = self._upload_file_webdav(connection, local_path, remote_path)
            elif storage_type == "smb":
                result = self._upload_file_smb(connection, local_path, remote_path)
            elif storage_type == "nfs":
                result = self._upload_file_nfs(connection, local_path, remote_path)
            
            if not result or result.get("status") != "success":
                self.logger.error(f"העלאת קובץ לנתיב {remote_path} נכשלה")
                return result or {
                    "status": "error",
                    "error": f"העלאת קובץ לנתיב {remote_path} נכשלה",
                    "local_path": local_path,
                    "remote_path": remote_path
                }
            
            # עדכון מטמון
            if self.cache_enabled:
                cache_key = f"{connection_id}_{remote_path}_content"
                self._cache_file(cache_key, local_path)
                
                # מחיקת רשימת קבצים במטמון (כי היא השתנתה)
                parent_dir = os.path.dirname(remote_path)
                parent_cache_key = f"{connection_id}_{parent_dir}"
                self._invalidate_cache(parent_cache_key)
            
            self.logger.info(f"העלאת קובץ לנתיב {remote_path} הושלמה בהצלחה")
            
            return result
            
        except Exception as e:
            self.logger.error(f"שגיאה בהעלאת קובץ לאחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "local_path": local_path,
                "remote_path": remote_path,
                "traceback": traceback.format_exc()
            }
    
    def delete_file(self, remote_path: str, connection_id: Optional[str] = None) -> Dict[str, Any]:
        """
        מחיקת קובץ מאחסון מרוחק
        
        Args:
            remote_path: נתיב הקובץ באחסון המרוחק
            connection_id: מזהה חיבור (אם לא צוין, ישמש החיבור הנוכחי)
            
        Returns:
            Dict[str, Any]: תוצאות המחיקה
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return {"status": "error", "error": "מנהל האחסון המרוחק לא אותחל"}
        
        try:
            # החלטה איזה חיבור לשמש
            if not connection_id:
                connection_id = self.current_connection
            
            if not connection_id or connection_id not in self.connections:
                self.logger.error(f"חיבור {connection_id} לא נמצא")
                return {
                    "status": "error",
                    "error": f"חיבור {connection_id} לא נמצא",
                    "remote_path": remote_path
                }
            
            # שליפת פרטי החיבור
            connection_info = self.connections[connection_id]
            connection = connection_info["connection"]
            storage_type = connection_info["type"]
            
            # מחיקת הקובץ לפי סוג האחסון
            result = None
            
            if storage_type == "local":
                result = self._delete_file_local(connection, remote_path)
            elif storage_type == "ssh":
                result = self._delete_file_ssh(connection, remote_path)
            elif storage_type == "s3":
                result = self._delete_file_s3(connection, remote_path)
            elif storage_type == "ftp":
                result = self._delete_file_ftp(connection, remote_path)
            elif storage_type == "webdav":
                result = self._delete_file_webdav(connection, remote_path)
            elif storage_type == "smb":
                result = self._delete_file_smb(connection, remote_path)
            elif storage_type == "nfs":
                result = self._delete_file_nfs(connection, remote_path)
            
            if not result or result.get("status") != "success":
                self.logger.error(f"מחיקת קובץ מנתיב {remote_path} נכשלה")
                return result or {
                    "status": "error",
                    "error": f"מחיקת קובץ מנתיב {remote_path} נכשלה",
                    "remote_path": remote_path
                }
            
            # עדכון מטמון
            if self.cache_enabled:
                # מחיקת הקובץ מהמטמון
                cache_key = f"{connection_id}_{remote_path}_content"
                self._invalidate_cache(cache_key)
                
                # מחיקת רשימת קבצים במטמון (כי היא השתנתה)
                parent_dir = os.path.dirname(remote_path)
                parent_cache_key = f"{connection_id}_{parent_dir}"
                self._invalidate_cache(parent_cache_key)
            
            self.logger.info(f"מחיקת קובץ מנתיב {remote_path} הושלמה בהצלחה")
            
            return result
            
        except Exception as e:
            self.logger.error(f"שגיאה במחיקת קובץ מאחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "remote_path": remote_path,
                "traceback": traceback.format_exc()
            }
    
    def make_directory(self, remote_path: str, connection_id: Optional[str] = None) -> Dict[str, Any]:
        """
        יצירת תיקייה באחסון מרוחק
        
        Args:
            remote_path: נתיב התיקייה באחסון המרוחק
            connection_id: מזהה חיבור (אם לא צוין, ישמש החיבור הנוכחי)
            
        Returns:
            Dict[str, Any]: תוצאות היצירה
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return {"status": "error", "error": "מנהל האחסון המרוחק לא אותחל"}
        
        try:
            # החלטה איזה חיבור לשמש
            if not connection_id:
                connection_id = self.current_connection
            
            if not connection_id or connection_id not in self.connections:
                self.logger.error(f"חיבור {connection_id} לא נמצא")
                return {
                    "status": "error",
                    "error": f"חיבור {connection_id} לא נמצא",
                    "remote_path": remote_path
                }
            
            # שליפת פרטי החיבור
            connection_info = self.connections[connection_id]
            connection = connection_info["connection"]
            storage_type = connection_info["type"]
            
            # יצירת התיקייה לפי סוג האחסון
            result = None
            
            if storage_type == "local":
                result = self._make_directory_local(connection, remote_path)
            elif storage_type == "ssh":
                result = self._make_directory_ssh(connection, remote_path)
            elif storage_type == "s3":
                result = self._make_directory_s3(connection, remote_path)
            elif storage_type == "ftp":
                result = self._make_directory_ftp(connection, remote_path)
            elif storage_type == "webdav":
                result = self._make_directory_webdav(connection, remote_path)
            elif storage_type == "smb":
                result = self._make_directory_smb(connection, remote_path)
            elif storage_type == "nfs":
                result = self._make_directory_nfs(connection, remote_path)
            
            if not result or result.get("status") != "success":
                self.logger.error(f"יצירת תיקייה בנתיב {remote_path} נכשלה")
                return result or {
                    "status": "error",
                    "error": f"יצירת תיקייה בנתיב {remote_path} נכשלה",
                    "remote_path": remote_path
                }
            
            # עדכון מטמון
            if self.cache_enabled:
                # מחיקת רשימת קבצים במטמון (כי היא השתנתה)
                parent_dir = os.path.dirname(remote_path)
                parent_cache_key = f"{connection_id}_{parent_dir}"
                self._invalidate_cache(parent_cache_key)
            
            self.logger.info(f"יצירת תיקייה בנתיב {remote_path} הושלמה בהצלחה")
            
            return result
            
        except Exception as e:
            self.logger.error(f"שגיאה ביצירת תיקייה באחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "remote_path": remote_path,
                "traceback": traceback.format_exc()
            }
    
    def scan_directory(self, remote_path: str, recursive: bool = True, connection_id: Optional[str] = None) -> Dict[str, Any]:
        """
        סריקת תיקייה באחסון מרוחק
        
        Args:
            remote_path: נתיב התיקייה באחסון המרוחק
            recursive: האם לסרוק באופן רקורסיבי
            connection_id: מזהה חיבור (אם לא צוין, ישמש החיבור הנוכחי)
            
        Returns:
            Dict[str, Any]: תוצאות הסריקה
        """
        if not self.initialized:
            self.logger.error("מנהל האחסון המרוחק לא אותחל")
            return {"status": "error", "error": "מנהל האחסון המרוחק לא אותחל"}
        
        try:
            # החלטה איזה חיבור לשמש
            if not connection_id:
                connection_id = self.current_connection
            
            if not connection_id or connection_id not in self.connections:
                self.logger.error(f"חיבור {connection_id} לא נמצא")
                return {
                    "status": "error",
                    "error": f"חיבור {connection_id} לא נמצא",
                    "remote_path": remote_path
                }
            
            # שליפת פרטי החיבור
            connection_info = self.connections[connection_id]
            connection = connection_info["connection"]
            storage_type = connection_info["type"]
            
            # בדיקה במטמון
            cache_key = f"{connection_id}_{remote_path}_scan_{recursive}"
            if self.cache_enabled:
                cached_result = self._get_from_cache(cache_key)
                if cached_result:
                    self.logger.debug(f"נמצא במטמון: סריקת תיקייה עבור {remote_path}")
                    return cached_result
            
            # תוצאות בסיסיות
            results = {
                "status": "success",
                "path": remote_path,
                "files": [],
                "directories": [],
                "recursive": recursive,
                "connection_id": connection_id
            }
            
            # רשימת קבצים בתיקייה הנוכחית
            list_result = self.list_files(remote_path, connection_id)
            
            if list_result.get("status") != "success":
                return list_result
            
            # הוספת קבצים ותיקיות מהתיקייה הנוכחית
            results["files"].extend(list_result.get("files", []))
            results["directories"].extend(list_result.get("directories", []))
            
            # אם נדרש רקורסיה, סריקת תתי-תיקיות
            if recursive:
                for directory in list_result.get("directories", []):
                    dir_path = directory.get("path")
                    if dir_path:
                        # סריקת תת-תיקייה
                        sub_result = self.scan_directory(dir_path, True, connection_id)
                        
                        if sub_result.get("status") == "success":
                            results["files"].extend(sub_result.get("files", []))
                            results["directories"].extend(sub_result.get("directories", []))
            
            # סיכום
            results["total_files"] = len(results["files"])
            results["total_directories"] = len(results["directories"])
            
            # שמירה במטמון
            if self.cache_enabled:
                self._save_to_cache(cache_key, results)
            
            self.logger.info(f"סריקת תיקייה {remote_path} הושלמה בהצלחה")
            
            return results
            
        except Exception as e:
            self.logger.error(f"שגיאה בסריקת תיקייה באחסון מרוחק: {str(e)}")
            self.logger.error(traceback.format_exc())
            
            return {
                "status": "error",
                "error": str(e),
                "remote_path": remote_path,
                "recursive": recursive,
                "traceback": traceback.format_exc()
            }
    
    # מימוש פרטני לכל סוג אחסון
    
    def _connect_local(self, params: Dict[str, Any]) -> Any:
        """חיבור לאחסון מקומי"""
        base_path = params.get("base_path", "")
        
        if not base_path:
            base_path = os.getcwd()
        
        if not os.path.isdir(base_path):
            self.logger.error(f"הנתיב המקומי {base_path} אינו קיים")
            return None
        
        return {"base_path": os.path.abspath(base_path)}
    
    def _connect_ssh(self, params: Dict[str, Any]) -> Any:
        """חיבור לאחסון SSH"""
        try:
            import paramiko
        except ImportError:
            self.logger.error("ספריית paramiko לא מותקנת. התקן באמצעות: pip install paramiko")
            return None
        
        host = params.get("host", "")
        port = params.get("port", 22)
        username = params.get("username", "")
        password = params.get("password", "")
        key_path = params.get("key_path", "")
        
        if not host:
            self.logger.error("חסר פרמטר 'host' לחיבור SSH")
            return None
        
        if not username:
            self.logger.error("חסר פרמטר 'username' לחיבור SSH")
            return None
        
        try:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            if key_path and os.path.isfile(key_path):
                # חיבור עם מפתח
                key = paramiko.RSAKey.from_private_key_file(key_path)
                client.connect(host, port=port, username=username, pkey=key, timeout=self.timeout_seconds)
            else:
                # חיבור עם סיסמה
                client.connect(host, port=port, username=username, password=password, timeout=self.timeout_seconds)
            
            # פתיחת חיבור SFTP
            sftp = client.open_sftp()
            
            return {
                "client": client,
                "sftp": sftp
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בחיבור SSH: {str(e)}")
            return None
    
    def _connect_s3(self, params: Dict[str, Any]) -> Any:
        """חיבור לאחסון S3"""
        try:
            import boto3
        except ImportError:
            self.logger.error("ספריית boto3 לא מותקנת. התקן באמצעות: pip install boto3")
            return None
        
        access_key = params.get("access_key", "")
        secret_key = params.get("secret_key", "")
        region = params.get("region", "us-east-1")
        bucket = params.get("bucket", "")
        
        if not bucket:
            self.logger.error("חסר פרמטר 'bucket' לחיבור S3")
            return None
        
        try:
            # יצירת חיבור לשירות S3
            if access_key and secret_key:
                s3 = boto3.client(
                    's3',
                    aws_access_key_id=access_key,
                    aws_secret_access_key=secret_key,
                    region_name=region
                )
            else:
                # שימוש בהגדרות ברירת מחדל
                s3 = boto3.client('s3', region_name=region)
            
            # בדיקת קיום הדלי
            s3.head_bucket(Bucket=bucket)
            
            return {
                "client": s3,
                "bucket": bucket
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בחיבור S3: {str(e)}")
            return None
    
    def _connect_ftp(self, params: Dict[str, Any]) -> Any:
        """חיבור לאחסון FTP"""
        try:
            from ftplib import FTP
        except ImportError:
            self.logger.error("תקלה בטעינת מודול FTP")
            return None
        
        host = params.get("host", "")
        port = params.get("port", 21)
        username = params.get("username", "")
        password = params.get("password", "")
        
        if not host:
            self.logger.error("חסר פרמטר 'host' לחיבור FTP")
            return None
        
        try:
            # יצירת חיבור FTP
            ftp = FTP()
            ftp.connect(host, port, timeout=self.timeout_seconds)
            
            if username:
                ftp.login(username, password)
            else:
                ftp.login()
            
            return {
                "client": ftp
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בחיבור FTP: {str(e)}")
            return None
    
    def _connect_webdav(self, params: Dict[str, Any]) -> Any:
        """חיבור לאחסון WebDAV"""
        try:
            import webdav3.client as wc
        except ImportError:
            self.logger.error("ספריית webdav3 לא מותקנת. התקן באמצעות: pip install webdav3")
            return None
        
        host = params.get("host", "")
        username = params.get("username", "")
        password = params.get("password", "")
        
        if not host:
            self.logger.error("חסר פרמטר 'host' לחיבור WebDAV")
            return None
        
        try:
            # הגדרות לחיבור WebDAV
            options = {
                'webdav_hostname': host,
                'webdav_login': username,
                'webdav_password': password,
                'timeout': self.timeout_seconds
            }
            
            # יצירת חיבור
            client = wc.Client(options)
            
            # בדיקת חיבור
            client.check()
            
            return {
                "client": client
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בחיבור WebDAV: {str(e)}")
            return None
    
    def _connect_smb(self, params: Dict[str, Any]) -> Any:
        """חיבור לאחסון SMB"""
        try:
            from smb.SMBConnection import SMBConnection
        except ImportError:
            self.logger.error("ספריית pysmb לא מותקנת. התקן באמצעות: pip install pysmb")
            return None
        
        host = params.get("host", "")
        username = params.get("username", "")
        password = params.get("password", "")
        domain = params.get("domain", "")
        share = params.get("share", "")
        
        if not host:
            self.logger.error("חסר פרמטר 'host' לחיבור SMB")
            return None
        
        if not share:
            self.logger.error("חסר פרמטר 'share' לחיבור SMB")
            return None
        
        try:
            # יצירת חיבור SMB
            conn = SMBConnection(
                username,
                password,
                "CLIENT",
                host,
                domain=domain,
                use_ntlm_v2=True
            )
            
            # התחברות
            conn.connect(host, 139)
            
            return {
                "client": conn,
                "share": share
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בחיבור SMB: {str(e)}")
            return None
    
    def _connect_nfs(self, params: Dict[str, Any]) -> Any:
        """חיבור לאחסון NFS"""
        # NFS דורש התקנת חבילות מערכת והרשאות מיוחדות
        # לכן אנחנו מספקים פתרון פשוט יחסית
        
        host = params.get("host", "")
        path = params.get("path", "")
        mount_point = params.get("mount_point", "")
        
        if not host or not path:
            self.logger.error("חסרים פרמטרים 'host' ו-'path' לחיבור NFS")
            return None
        
        if not mount_point:
            # יצירת נקודת עיגון זמנית
            mount_point = tempfile.mkdtemp(prefix="nfs_mount_")
        
        try:
            # ניסיון לעגן את ה-NFS
            cmd = ["mount", "-t", "nfs", f"{host}:{path}", mount_point]
            
            result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            if result.returncode != 0:
                self.logger.error(f"שגיאה בעיגון NFS: {result.stderr}")
                return None
            
            return {
                "mount_point": mount_point,
                "host": host,
                "path": path
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בחיבור NFS: {str(e)}")
            return None
    
    # פונקציות ניתוק
    
    def _disconnect_ssh(self, connection: Dict[str, Any]) -> bool:
        """ניתוק מאחסון SSH"""
        try:
            sftp = connection.get("sftp")
            client = connection.get("client")
            
            if sftp:
                sftp.close()
            
            if client:
                client.close()
            
            return True
            
        except Exception as e:
            self.logger.error(f"שגיאה בניתוק מאחסון SSH: {str(e)}")
            return False
    
    def _disconnect_ftp(self, connection: Dict[str, Any]) -> bool:
        """ניתוק מאחסון FTP"""
        try:
            client = connection.get("client")
            
            if client:
                client.quit()
            
            return True
            
        except Exception as e:
            self.logger.error(f"שגיאה בניתוק מאחסון FTP: {str(e)}")
            return False
    
    def _disconnect_webdav(self, connection: Dict[str, Any]) -> bool:
        """ניתוק מאחסון WebDAV"""
        # אין צורך בניתוק מיוחד
        return True
    
    def _disconnect_smb(self, connection: Dict[str, Any]) -> bool:
        """ניתוק מאחסון SMB"""
        try:
            client = connection.get("client")
            
            if client:
                client.close()
            
            return True
            
        except Exception as e:
            self.logger.error(f"שגיאה בניתוק מאחסון SMB: {str(e)}")
            return False
    
    def _disconnect_nfs(self, connection: Dict[str, Any]) -> bool:
        """ניתוק מאחסון NFS"""
        try:
            mount_point = connection.get("mount_point")
            
            if mount_point and os.path.ismount(mount_point):
                # ניתוק ה-NFS
                cmd = ["umount", mount_point]
                
                result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                
                if result.returncode != 0:
                    self.logger.error(f"שגיאה בניתוק NFS: {result.stderr}")
                    return False
                
                # מחיקת תיקייה זמנית
                if os.path.exists(mount_point):
                    os.rmdir(mount_point)
            
            return True
            
        except Exception as e:
            self.logger.error(f"שגיאה בניתוק מאחסון NFS: {str(e)}")
            return False
    
    # פונקציות רשימת קבצים
    
    def _list_files_local(self, connection: Dict[str, Any], path: str) -> Dict[str, Any]:
        """רשימת קבצים באחסון מקומי"""
        base_path = connection.get("base_path", "")
        full_path = os.path.join(base_path, path.lstrip('/'))
        
        if not os.path.exists(full_path):
            return {
                "status": "error",
                "error": f"הנתיב {path} אינו קיים",
                "path": path
            }
        
        if not os.path.isdir(full_path):
            return {
                "status": "error",
                "error": f"הנתיב {path} אינו תיקייה",
                "path": path
            }
        
        try:
            files = []
            directories = []
            
            for item in os.listdir(full_path):
                item_path = os.path.join(full_path, item)
                rel_path = os.path.join(path, item).replace('\\', '/')
                
                if os.path.isdir(item_path):
                    directories.append({
                        "name": item,
                        "path": rel_path,
                        "type": "directory",
                        "size": 0,
                        "mtime": os.path.getmtime(item_path)
                    })
                else:
                    files.append({
                        "name": item,
                        "path": rel_path,
                        "type": "file",
                        "size": os.path.getsize(item_path),
                        "mtime": os.path.getmtime(item_path)
                    })
            
            return {
                "status": "success",
                "path": path,
                "files": files,
                "directories": directories
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה ברשימת קבצים מקומית בנתיב {path}: {str(e)}")
            return {
                "status": "error",
                "error": str(e),
                "path": path
            }
    
    def _list_files_ssh(self, connection: Dict[str, Any], path: str) -> Dict[str, Any]:
        """רשימת קבצים באחסון SSH"""
        sftp = connection.get("sftp")
        
        if not sftp:
            return {
                "status": "error",
                "error": "חיבור SFTP לא זמין",
                "path": path
            }
        
        try:
            files = []
            directories = []
            
            for item in sftp.listdir_attr(path):
                item_name = item.filename
                item_path = os.path.join(path, item_name).replace('\\', '/')
                
                if stat.S_ISDIR(item.st_mode):
                    directories.append({
                        "name": item_name,
                        "path": item_path,
                        "type": "directory",
                        "size": 0,
                        "mtime": item.st_mtime
                    })
                else:
                    files.append({
                        "name": item_name,
                        "path": item_path,
                        "type": "file",
                        "size": item.st_size,
                        "mtime": item.st_mtime
                    })
            
            return {
                "status": "success",
                "path": path,
                "files": files,
                "directories": directories
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה ברשימת קבצים SSH בנתיב {path}: {str(e)}")
            return {
                "status": "error",
                "error": str(e),
                "path": path
            }
    
    # כאן יש להוסיף את המימוש של שאר הפונקציות הפרטיות
    # (יש לבצע מימוש עבור כל סוג אחסון ולכל פעולה):
    # - _list_files_s3, _list_files_ftp, וכו'
    # - _download_file_local, _download_file_ssh, וכו'
    # - _upload_file_local, _upload_file_ssh, וכו'
    # - _delete_file_local, _delete_file_ssh, וכו'
    # - _make_directory_local, _make_directory_ssh, וכו'
    
    # פונקציות מטמון
    
    def _get_from_cache(self, key: str) -> Optional[Dict[str, Any]]:
        """קבלת ערך מהמטמון"""
        if not self.cache_enabled:
            return None
        
        cache_file = os.path.join(self.cache_dir, f"{key}.json")
        
        if not os.path.exists(cache_file):
            return None
        
        # בדיקת תוקף המטמון
        if time.time() - os.path.getmtime(cache_file) > self.cache_expiry_seconds:
            # המטמון פג תוקף
            try:
                os.remove(cache_file)
            except:
                pass
            return None
        
        try:
            with open(cache_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except:
            return None
    
    def _save_to_cache(self, key: str, value: Dict[str, Any]) -> bool:
        """שמירת ערך במטמון"""
        if not self.cache_enabled:
            return False
        
        cache_file = os.path.join(self.cache_dir, f"{key}.json")
        
        try:
            with open(cache_file, 'w', encoding='utf-8') as f:
                json.dump(value, f, ensure_ascii=False, indent=2)
            return True
        except:
            return False
    
    def _get_cached_file(self, key: str) -> Optional[str]:
        """קבלת קובץ מהמטמון"""
        if not self.cache_enabled:
            return None
        
        cache_file = os.path.join(self.cache_dir, f"{key}")
        
        if not os.path.exists(cache_file):
            return None
        
        # בדיקת תוקף המטמון
        if time.time() - os.path.getmtime(cache_file) > self.cache_expiry_seconds:
            # המטמון פג תוקף
            try:
                os.remove(cache_file)
            except:
                pass
            return None
        
        return cache_file
    
    def _cache_file(self, key: str, file_path: str) -> bool:
        """שמירת קובץ במטמון"""
        if not self.cache_enabled:
            return False
        
        cache_file = os.path.join(self.cache_dir, f"{key}")
        
        try:
            shutil.copy2(file_path, cache_file)
            return True
        except:
            return False
    
    def _invalidate_cache(self, key: str) -> bool:
        """ביטול תוקף ערך במטמון"""
        if not self.cache_enabled:
            return False
        
        cache_file = os.path.join(self.cache_dir, f"{key}.json")
        
        if os.path.exists(cache_file):
            try:
                os.remove(cache_file)
                return True
            except:
                return False
        
        return True
    
    def _check_dependencies(self) -> None:
        """בדיקת תלויות"""
        # בדיקת תלויות לפי סוגי אחסון נתמכים
        supported_storage_types = self.config.get("types", ["local", "ssh", "s3", "ftp", "webdav", "smb", "nfs"])
        
        # בדיקת תלויות SSH
        if "ssh" in supported_storage_types:
            try:
                import paramiko
                self.logger.info("ספריית paramiko נמצאה - תמיכה ב-SSH זמינה")
            except ImportError:
                self.logger.warning("ספריית paramiko לא מותקנת. תמיכה ב-SSH לא זמינה.")
                self.logger.warning("להתקנה: pip install paramiko")
        
        # בדיקת תלויות S3
        if "s3" in supported_storage_types:
            try:
                import boto3
                self.logger.info("ספריית boto3 נמצאה - תמיכה ב-S3 זמינה")
            except ImportError:
                self.logger.warning("ספריית boto3 לא מותקנת. תמיכה ב-S3 לא זמינה.")
                self.logger.warning("להתקנה: pip install boto3")
        
        # בדיקת תלויות WebDAV
        if "webdav" in supported_storage_types:
            try:
                import webdav3.client
                self.logger.info("ספריית webdav3 נמצאה - תמיכה ב-WebDAV זמינה")
            except ImportError:
                self.logger.warning("ספריית webdav3 לא מותקנת. תמיכה ב-WebDAV לא זמינה.")
                self.logger.warning("להתקנה: pip install webdav3")
        
        # בדיקת תלויות SMB
        if "smb" in supported_storage_types:
            try:
                from smb.SMBConnection import SMBConnection
                self.logger.info("ספריית pysmb נמצאה - תמיכה ב-SMB זמינה")
            except ImportError:
                self.logger.warning("ספריית pysmb לא מותקנת. תמיכה ב-SMB לא זמינה.")
                self.logger.warning("להתקנה: pip install pysmb")