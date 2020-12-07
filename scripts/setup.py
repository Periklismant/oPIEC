from setuptools import setup

setup(
	name='oPIEC',
	version='1.0',
	py_modules=['oPIEC'],
	install_requires=[
		'Click', 'problog', 'intervaltree'
	],
	entry_points='''
		[console_scripts]
		oPIEC=oPIEC_cli:cli
	''',
)