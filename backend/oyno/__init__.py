"""Project package initialization.

Contains compatibility patches applied at import time.
"""


def _patch_django_basecontext_copy() -> None:
	"""Work around Django 4.2 incompatibility with Python 3.14 copy(super()).

	Django 4.2's BaseContext.__copy__ uses copy(super()), which raises
	AttributeError on Python 3.14. Admin changelist rendering triggers this.
	"""
	try:
		from django.template.context import BaseContext

		def _safe_copy(self):
			duplicate = self.__class__.__new__(self.__class__)
			if hasattr(self, '__dict__'):
				duplicate.__dict__ = self.__dict__.copy()
			duplicate.dicts = self.dicts[:]
			return duplicate

		BaseContext.__copy__ = _safe_copy
	except Exception:
		# Do not break startup if Django internals change.
		pass


_patch_django_basecontext_copy()

