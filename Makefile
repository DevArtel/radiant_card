compile:
	glslc \
	  --target-env=opengl \
	  -fshader-stage=fragment \
	  -o assets/shaders/phong.sprv \
	  shaders/phong.glsl