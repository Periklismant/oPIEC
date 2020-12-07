from setuptools import setup

setup(
	name='oPIEC',
	version='1.0',
	py_modules=['oPIEC'],
	install_requires=[
		'Click', 'problog', 'intervaltree'
	],
	scripts=['scripts/oPIEC_cli.py','src/oPIEC-python/oPIEC.py', 'src/oPIEC-python/utils.py','src/oPIEC-python/ssResolver.py'],
	package_data = {'oPIEC': ['datasets/*']},
	entry_points={
		'console_scripts':['oPIEC=oPIEC_cli:cli'],
                },
)
