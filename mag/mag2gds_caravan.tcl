	random seed 15; 	drc off; 	crashbackups stop; 	addpath hexdigits; 	addpath /home/jona/Desktop/Repositorio_LAB/test_mixer/mgmt_core_wrapper/mag; 	addpath /home/jona/Desktop/Repositorio_LAB/test_mixer/mag; 	load user_analog_project_wrapper; 	property LEFview true; 	property GDS_FILE /home/jona/Desktop/Repositorio_LAB/test_mixer/gds/user_analog_project_wrapper.gds; 	property GDS_START 0; 	load /home/jona/Desktop/Repositorio_LAB/test_mixer/mag/user_id_programming; 	load /home/jona/Desktop/Repositorio_LAB/test_mixer/mag/user_id_textblock; 	load /home/jona/Desktop/Repositorio_LAB/test_mixer/caravel/maglef/simple_por; 	load /home/jona/Desktop/Repositorio_LAB/test_mixer/mag/caravan_core -dereference; 	load caravan -dereference; 	select top cell; 	expand; 	cif *hier write disable; 	cif *array write disable; 	gds write /home/jona/Desktop/Repositorio_LAB/test_mixer/gds/caravan.gds; 	quit -noprompt;