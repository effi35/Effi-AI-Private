# ייבוא מודולים חדשים
try:
    from .core.project_detector import ProjectDetector
    from .core.file_analyzer import FileAnalyzer
    from .core.merger import FileMerger, SystemMerger
    from .core.document_analyzer import DocumentAnalyzer
    from .core.relationship_graph import RelationshipGraph
    from .core.report_generator import ReportGenerator
    from .core.log_manager import setup_logging
    from .core.version_manager import VersionManager  # חדש
    from .core.security_scanner import SecurityScanner  # חדש
    from .core.code_runner import CodeRunner  # חדש
    from .core.code_completer import CodeCompleter  # חדש
    from .ui.gui_manager import GUIManager
    from .utils.helpers import get_file_hash, is_binary_file, path_to_relative
    from .utils.diff_viewer import DiffViewer  # חדש
    from .utils.remote_storage import RemoteStorage  # חדש
    from .utils.media_handler import MediaHandler  # חדש
except ImportError:
    # במקרה של ייבוא ישיר
    from core.project_detector import ProjectDetector
    from core.file_analyzer import FileAnalyzer
    from core.merger import FileMerger, SystemMerger
    from core.document_analyzer import DocumentAnalyzer
    from core.relationship_graph import RelationshipGraph
    from core.report_generator import ReportGenerator
    from core.log_manager import setup_logging
    from core.version_manager import VersionManager  # חדש
    from core.security_scanner import SecurityScanner  # חדש
    from core.code_runner import CodeRunner  # חדש
    from core.code_completer import CodeCompleter  # חדש
    from ui.gui_manager import GUIManager
    from utils.helpers import get_file_hash, is_binary_file, path_to_relative
    from utils.diff_viewer import DiffViewer  # חדש
    from utils.remote_storage import RemoteStorage  # חדש
    from utils.media_handler import MediaHandler  # חדש