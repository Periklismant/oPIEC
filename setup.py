from setuptools import setup, find_packages

setup(
	name='oPIEC',
	version='1.0',
	py_modules=['oPIEC'],
	install_requires=[
		'Click', 'problog', 'intervaltree'
	],
	packages=['oPIEC_scripts', 'Prob-EC'],
	package_data = {
		'oPIEC_scripts': ['*.py'],
		'Prob-EC': ['*.pl']
	},
	scripts=['oPIEC_scripts/scripts/oPIEC_cli.py'],
	entry_points={
		'console_scripts':['oPIEC=oPIEC_cli:cli'],
                },
)
