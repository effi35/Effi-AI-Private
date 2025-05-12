import os
import json
import shutil
import hashlib
import datetime
import gzip
import tempfile
import logging
from typing import Dict, List, Any, Optional, Union, Tuple
import difflib

class VersionManager:
    """מנהל גרסאות למאחד קוד חכם Pro 2.0"""
    
    def __init__(self):
        self.initialized = False
        self.config = {}
        self.versions_dir = ""
        self.logger = logging.getLogger(__name__)
    
    def initialize(self, config: Dict[str, Any]) -> bool:
        """אתחול מנהל הגרסאות"""
        self.config = config
        
        # קביעת תיקיית הגרסאות
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.versions_dir = os.path.join(base_dir, config.get("storage_path", "versions"))
        
        # יצירת תיקיית גרסאות אם לא קיימת
        if not os.path.exists(self.versions_dir):
            os.makedirs(self.versions_dir, exist_ok=True)
        
        # הגדרת מספר גרסאות מקסימלי לשמירה
        self.max_versions = config.get("max_versions", 10)
        
        # הגדרת דחיסה
        self.compression = config.get("compression", "gzip")
        
        # הגדרת שמירת מטא-דאטה
        self.include_metadata = config.get("include_metadata", True)
        
        # אתחול מדד התוכן
        self._initialize_index()
        
        self.initialized = True
        self.logger.info("מנהל הגרסאות אותחל בהצלחה")
        
        return True
    
    def shutdown(self) -> bool:
        """כיבוי מנהל הגרסאות"""
        # שמירת מדד התוכן
        self._save_index()
        
        self.initialized = False
        self.logger.info("מנהל הגרסאות כובה בהצלחה")
        
        return True
    
    def add_version(self, file_path: str, rel_path: str, metadata: Optional[Dict[str, Any]] = None) -> str:
        """הוספת גרסה חדשה של קובץ"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return ""
        
        try:
            # חישוב מזהה קובץ
            file_id = self._get_file_id(rel_path)
            
            # חישוב hash של הקובץ
            file_hash = self._calculate_hash(file_path)
            
            # יצירת מטא-דאטה לגרסה
            version_metadata = {
                "timestamp": datetime.datetime.now().isoformat(),
                "file_path": file_path,
                "rel_path": rel_path,
                "hash": file_hash,
                "size": os.path.getsize(file_path)
            }
            
            # הוספת מטא-דאטה נוסף אם סופק
            if metadata and self.include_metadata:
                version_metadata.update(metadata)
            
            # יצירת מזהה לגרסה
            version_id = f"{file_id}_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}_{file_hash[:8]}"
            
            # יצירת תיקיית גרסאות לקובץ אם לא קיימת
            file_versions_dir = os.path.join(self.versions_dir, file_id)
            os.makedirs(file_versions_dir, exist_ok=True)
            
            # העתקת הקובץ לתיקיית הגרסאות
            version_path = os.path.join(file_versions_dir, f"{version_id}")
            
            # שמירת הקובץ (עם או בלי דחיסה)
            if self.compression == "gzip":
                self._save_compressed(file_path, version_path + ".gz")
            else:
                shutil.copy2(file_path, version_path)
            
            # שמירת מטא-דאטה
            if self.include_metadata:
                with open(version_path + ".meta.json", 'w', encoding='utf-8') as f:
                    json.dump(version_metadata, f, ensure_ascii=False, indent=2, default=str)
            
            # עדכון מדד התוכן
            self._update_index(file_id, rel_path, version_id, version_metadata)
            
            # גיזום גרסאות ישנות אם יש יותר מדי
            self._prune_old_versions(file_id)
            
            self.logger.info(f"נוספה גרסה חדשה {version_id} לקובץ {rel_path}")
            return version_id
            
        except Exception as e:
            self.logger.error(f"שגיאה בהוספת גרסה חדשה לקובץ {rel_path}: {str(e)}")
            return ""
    
    def get_version(self, version_id: str, target_path: Optional[str] = None) -> Union[str, bool]:
        """אחזור גרסה ספציפית של קובץ"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return False
        
        try:
            # פירוק מזהה הגרסה
            parts = version_id.split('_')
            if len(parts) < 3:
                self.logger.error(f"מזהה גרסה לא תקין: {version_id}")
                return False
            
            file_id = parts[0]
            
            # בדיקת קיום הגרסה
            file_versions_dir = os.path.join(self.versions_dir, file_id)
            if not os.path.exists(file_versions_dir):
                self.logger.error(f"תיקיית גרסאות לא קיימת עבור {file_id}")
                return False
            
            # חיפוש קובץ הגרסה
            version_path = None
            if self.compression == "gzip":
                version_path = os.path.join(file_versions_dir, f"{version_id}.gz")
            else:
                version_path = os.path.join(file_versions_dir, f"{version_id}")
            
            if not os.path.exists(version_path):
                self.logger.error(f"גרסה לא קיימת: {version_id}")
                return False
            
            # אם לא צוין נתיב יעד, יצירת קובץ זמני
            if target_path is None:
                temp_file = tempfile.NamedTemporaryFile(delete=False)
                target_path = temp_file.name
                temp_file.close()
            
            # פתיחת הגרסה והעתקתה לנתיב היעד
            if self.compression == "gzip":
                self._extract_compressed(version_path, target_path)
            else:
                shutil.copy2(version_path, target_path)
            
            self.logger.info(f"גרסה {version_id} שוחזרה בהצלחה")
            return target_path
            
        except Exception as e:
            self.logger.error(f"שגיאה באחזור גרסה {version_id}: {str(e)}")
            return False
    
    def get_versions(self, rel_path: str) -> List[Dict[str, Any]]:
        """קבלת רשימת כל הגרסאות של קובץ מסוים"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return []
        
        try:
            # חישוב מזהה קובץ
            file_id = self._get_file_id(rel_path)
            
            # קריאת מדד התוכן
            versions = []
            if file_id in self.index.get('files', {}):
                file_info = self.index['files'][file_id]
                
                # התאמה שהנתיב היחסי תואם
                if file_info.get('rel_path') == rel_path:
                    versions = file_info.get('versions', [])
            
            return versions
            
        except Exception as e:
            self.logger.error(f"שגיאה בקבלת גרסאות עבור {rel_path}: {str(e)}")
            return []
    
    def get_file_history(self, rel_path: str) -> List[Dict[str, Any]]:
        """קבלת היסטוריית גרסאות של קובץ עם מטא-דאטה"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return []
        
        try:
            # חישוב מזהה קובץ
            file_id = self._get_file_id(rel_path)
            
            # קריאת מדד התוכן
            if file_id not in self.index.get('files', {}):
                return []
            
            file_info = self.index['files'][file_id]
            
            # בניית היסטוריה עם מטא-דאטה
            history = []
            
            for version_id in file_info.get('version_ids', []):
                # חיפוש קובץ המטא-דאטה
                meta_path = os.path.join(self.versions_dir, file_id, f"{version_id}.meta.json")
                
                if os.path.exists(meta_path):
                    try:
                        with open(meta_path, 'r', encoding='utf-8') as f:
                            metadata = json.load(f)
                            
                            # הוספת מזהה הגרסה למטא-דאטה
                            metadata['version_id'] = version_id
                            
                            history.append(metadata)
                    except:
                        # אם אין אפשרות לקרוא את המטא-דאטה, הוספת מידע בסיסי
                        history.append({
                            'version_id': version_id,
                            'timestamp': 'unknown'
                        })
                else:
                    # אם אין קובץ מטא-דאטה, הוספת מידע בסיסי
                    history.append({
                        'version_id': version_id,
                        'timestamp': 'unknown'
                    })
            
            # מיון לפי חותמת זמן (מהחדש לישן)
            history.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
            
            return history
            
        except Exception as e:
            self.logger.error(f"שגיאה בקבלת היסטוריית גרסאות עבור {rel_path}: {str(e)}")
            return []
    
    def compare_versions(self, version_id1: str, version_id2: str) -> Union[Dict[str, Any], bool]:
        """השוואה בין שתי גרסאות של קובץ"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return False
        
        try:
            # אחזור הגרסאות לקבצים זמניים
            temp_file1 = self.get_version(version_id1)
            temp_file2 = self.get_version(version_id2)
            
            if not temp_file1 or not temp_file2:
                self.logger.error(f"לא ניתן לאחזר את הגרסאות להשוואה")
                return False
            
            # קריאת תוכן הקבצים
            with open(temp_file1, 'r', encoding='utf-8', errors='ignore') as f1:
                content1 = f1.read().splitlines()
            
            with open(temp_file2, 'r', encoding='utf-8', errors='ignore') as f2:
                content2 = f2.read().splitlines()
            
            # השוואת הקבצים
            diff = difflib.unified_diff(
                content1, 
                content2,
                fromfile=f'version_{version_id1}',
                tofile=f'version_{version_id2}',
                lineterm=''
            )
            
            # המרת התוצאה לרשימה
            diff_lines = list(diff)
            
            # ניקוי הקבצים הזמניים
            os.unlink(temp_file1)
            os.unlink(temp_file2)
            
            # חישוב סטטיסטיקות השוואה
            added_lines = sum(1 for line in diff_lines if line.startswith('+') and not line.startswith('+++'))
            removed_lines = sum(1 for line in diff_lines if line.startswith('-') and not line.startswith('---'))
            
            self.logger.info(f"בוצעה השוואה בין גרסאות {version_id1} ו-{version_id2}")
            
            return {
                'diff': diff_lines,
                'stats': {
                    'added_lines': added_lines,
                    'removed_lines': removed_lines,
                    'total_changes': added_lines + removed_lines
                }
            }
            
        except Exception as e:
            self.logger.error(f"שגיאה בהשוואת גרסאות {version_id1} ו-{version_id2}: {str(e)}")
            return False
    
    def get_latest_version(self, rel_path: str) -> Optional[str]:
        """קבלת הגרסה האחרונה של קובץ"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return None
        
        history = self.get_file_history(rel_path)
        
        if history:
            return history[0].get('version_id')
        
        return None
    
    def delete_version(self, version_id: str) -> bool:
        """מחיקת גרסה ספציפית"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return False
        
        try:
            # פירוק מזהה הגרסה
            parts = version_id.split('_')
            if len(parts) < 3:
                self.logger.error(f"מזהה גרסה לא תקין: {version_id}")
                return False
            
            file_id = parts[0]
            
            # בדיקת קיום הגרסה
            file_versions_dir = os.path.join(self.versions_dir, file_id)
            if not os.path.exists(file_versions_dir):
                self.logger.error(f"תיקיית גרסאות לא קיימת עבור {file_id}")
                return False
            
            # חיפוש קובץ הגרסה
            version_path = None
            meta_path = None
            
            if self.compression == "gzip":
                version_path = os.path.join(file_versions_dir, f"{version_id}.gz")
            else:
                version_path = os.path.join(file_versions_dir, f"{version_id}")
            
            meta_path = os.path.join(file_versions_dir, f"{version_id}.meta.json")
            
            # מחיקת הקבצים
            if os.path.exists(version_path):
                os.remove(version_path)
            
            if os.path.exists(meta_path):
                os.remove(meta_path)
            
            # עדכון מדד התוכן
            if file_id in self.index.get('files', {}):
                if version_id in self.index['files'][file_id].get('version_ids', []):
                    self.index['files'][file_id]['version_ids'].remove(version_id)
                    
                    # אם אין יותר גרסאות, מחיקת הקובץ מהמדד
                    if not self.index['files'][file_id]['version_ids']:
                        del self.index['files'][file_id]
                        
                        # מחיקת תיקיית הגרסאות אם ריקה
                        if os.path.exists(file_versions_dir) and not os.listdir(file_versions_dir):
                            os.rmdir(file_versions_dir)
            
            # שמירת מדד התוכן
            self._save_index()
            
            self.logger.info(f"גרסה {version_id} נמחקה בהצלחה")
            return True
            
        except Exception as e:
            self.logger.error(f"שגיאה במחיקת גרסה {version_id}: {str(e)}")
            return False
    
    def restore_version(self, version_id: str, target_path: str) -> bool:
        """שחזור גרסה ספציפית לנתיב יעד"""
        if not self.initialized:
            self.logger.error("מנהל הגרסאות לא אותחל")
            return False
        
        # פשוט משתמשים ב-get_version עם נתיב יעד מפורש
        result = self.get_version(version_id, target_path)
        
        return result is not False
    
    def _initialize_index(self) -> None:
        """אתחול מדד תוכן"""
        index_path = os.path.join(self.versions_dir, "index.json")
        
        if os.path.exists(index_path):
            try:
                with open(index_path, 'r', encoding='utf-8') as f:
                    self.index = json.load(f)
            except:
                self.logger.warning("לא ניתן לקרוא את מדד התוכן, יוצר חדש")
                self.index = {
                    'created': datetime.datetime.now().isoformat(),
                    'updated': datetime.datetime.now().isoformat(),
                    'files': {}
                }
        else:
            self.index = {
                'created': datetime.datetime.now().isoformat(),
                'updated': datetime.datetime.now().isoformat(),
                'files': {}
            }
    
    def _save_index(self) -> None:
        """שמירת מדד התוכן"""
        index_path = os.path.join(self.versions_dir, "index.json")
        
        try:
            # עדכון חותמת עדכון אחרונה
            self.index['updated'] = datetime.datetime.now().isoformat()
            
            with open(index_path, 'w', encoding='utf-8') as f:
                json.dump(self.index, f, ensure_ascii=False, indent=2, default=str)
        except Exception as e:
            self.logger.error(f"שגיאה בשמירת מדד התוכן: {str(e)}")
    
    def _update_index(self, file_id: str, rel_path: str, version_id: str, metadata: Dict[str, Any]) -> None:
        """עדכון מדד התוכן עם גרסה חדשה"""
        # יצירת רשומה לקובץ אם לא קיימת
        if file_id not in self.index.get('files', {}):
            self.index.setdefault('files', {})[file_id] = {
                'rel_path': rel_path,
                'version_ids': []
            }
        
        # הוספת מזהה הגרסה
        self.index['files'][file_id]['version_ids'].append(version_id)
        
        # שמירת מדד התוכן
        self._save_index()
    
    def _prune_old_versions(self, file_id: str) -> None:
        """גיזום גרסאות ישנות"""
        if file_id not in self.index.get('files', {}):
            return
        
        # בדיקה אם יש יותר מדי גרסאות
        version_ids = self.index['files'][file_id].get('version_ids', [])
        
        if len(version_ids) <= self.max_versions:
            return
        
        # מיון הגרסאות לפי תאריך (מהישן לחדש)
        version_ids.sort()
        
        # חישוב כמה גרסאות למחוק
        versions_to_remove = len(version_ids) - self.max_versions
        
        # מחיקת הגרסאות הישנות ביותר
        for i in range(versions_to_remove):
            old_version_id = version_ids[i]
            self.delete_version(old_version_id)
    
    def _get_file_id(self, rel_path: str) -> str:
        """יצירת מזהה קובץ מנתיב יחסי"""
        return hashlib.md5(rel_path.encode('utf-8')).hexdigest()
    
    def _calculate_hash(self, file_path: str) -> str:
        """חישוב hash של קובץ"""
        with open(file_path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    
    def _save_compressed(self, source_path: str, target_path: str) -> None:
        """שמירת קובץ בדחיסת gzip"""
        with open(source_path, 'rb') as f_in:
            with gzip.open(target_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
    
    def _extract_compressed(self, source_path: str, target_path: str) -> None:
        """חילוץ קובץ מדחיסת gzip"""
        with gzip.open(source_path, 'rb') as f_in:
            with open(target_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)