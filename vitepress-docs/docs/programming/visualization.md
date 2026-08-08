# Visualization

MuJoCo includes an interactive 3D visualizer rendered in OpenGL.

## Built-in Visualizer (simulate)

The `simulate` application provides a full-featured GUI:

```bash
# Launch with a model file
simulate model.xml

# Launch with a binary model
simulate model.mjb

# Launch empty (drag-and-drop model)
simulate
```

### Keyboard Controls

| Key | Action |
|-----|--------|
| `Space` | Pause / Resume |
| `Tab` | Toggle UI panels |
| `1-9` | Toggle visualization options |
| `R` | Reset simulation |
| `F` | Toggle fullscreen |
| `S` | Screenshot |

### Mouse Controls

| Action | Control |
|--------|---------|
| Rotate camera | Left drag |
| Pan camera | Right drag |
| Zoom | Scroll wheel |
| Select body | Click |
| Apply force | Click + drag (with tool selected) |

## Programmatic Visualization

```c
#include "mujoco.h"
#include <GLFW/glfw3.h>

mjvScene scene;
mjvCamera camera;
mjvOption opt;
mjrContext con;

// Initialize GLFW
glfwInit();
GLFWwindow* window = glfwCreateWindow(1024, 768, "MuJoCo Viewer", NULL, NULL);
glfwMakeContextCurrent(window);

// Initialize MuJoCo visualization
mjv_initScene(m, &scene, 1000);
mjv_defaultCamera(&camera);
mjv_defaultOption(&opt);
mjr_registerContext(&con);

// Rendering loop
while (!glfwWindowShouldClose(window)) {
  // Update scene
  mjv_updateScene(m, d, &opt, NULL, &camera, mjCAT_ALL);
  
  // Render
  mjr_rect(0, 0, 0, 0, 1);
  mjr_render(mjrConsoleSize(&con), &scene, &con);
  
  glfwSwapBuffers(window);
  glfwPollEvents();
}
```

## Visualization Options

```c
// Toggle visualization flags
opt.flags[mjVIS_CONTACTPOINT] = 1;    // Contact points
opt.flags[mjVIS_CONTACTFORCE] = 1;    // Contact forces
opt.flags[mjVIS_JOINT] = 1;           // Joint axes
opt.flags[mjVIS_AFFECTOR] = 1;        // Affectors
opt.flags[mjVIS_TENDON] = 1;          // Tendons
opt.flags[mjVIS_SITE] = 1;            // Sites
opt.flags[mjVIS_SENSOR] = 1;          // Sensors
opt.flags[mjVIS_COMPASS] = 1;         // Compass
opt.flags[mjVIS_INERTIA] = 1;         // Inertia boxes
opt.flags[mjVIS_EFFORT] = 1;          // Actuator effort
opt.flags[mjVIS_CONTACTFRICTION] = 1; // Friction forces
opt.flags[mjVIS_CONTACTSOLVER] = 1;   // Contact solver info
opt.flags[mjVIS_SKIN] = 1;            // Skinned meshes
opt.flags[mjVIS_GLUE] = 1;            // Glued contacts
opt.flags[mjVIS_TRANSPARENT] = 1;     // Transparent geoms
opt.flags[mjVIS_ISLAND] = 1;          // Constraint islands
opt.flags[mjVIS_MOVIE] = 1;           // Movie mode

// Rendering flags
opt.renderflags[mjRND_SHADOW] = 1;         // Shadows
opt.renderflags[mjRND_REFLECTION] = 1;     // Reflections
opt.renderflags[mjRND_SKYBOX] = 1;         // Skybox
opt.renderflags[mjRND_FOG] = 1;            // Fog
opt.renderflags[mjRND_HAZE] = 1;           // Haze
opt.renderflags[mjRND_SEGMENTS] = 1;       // Segment IDs
opt.renderflags[mjRND_ID] = 1;             // Entity IDs
opt.renderflags[mjRND_RIBBON] = 1;         // Ribbon visualization
opt.renderflags[mjRND_MULTIRIBBON] = 1;    // Multi-ribbon
opt.renderflags[mjRND_VEL] = 1;            // Velocity vectors
opt.renderflags[mjRND_ACC] = 1;            // Acceleration vectors
opt.renderflags[mjRND_FORCE] = 1;          // Force vectors
opt.renderflags[mjRND_TORQUE] = 1;         // Torque vectors
opt.renderflags[mjRND_JOINTXPOS] = 1;      // Joint position markers
opt.renderflags[mjRND_GEOMTEXTURE] = 1;    // Geom textures
opt.renderflags[mjRND_WIREFRAME] = 1;      // Wireframe mode
opt.renderflags[mjRND_TOOLLENGTH] = 1;     // Tool length
opt.renderflags[mjRND_SELECTABLE] = 1;     // Selectable objects
opt.renderflags[mjRND_COM] = 1;            // Center of mass
opt.renderflags[mjRND_TREE] = 1;           // Tree structure
opt.renderflags[mjRND_EULER23] = 1;        // Euler 2-3 order
opt.renderflags[mjRND_ARROWS] = 1;         // Arrow-style vectors
opt.renderflags[mjRND_EQACTIVE] = 1;       // Active equality constraints
opt.renderflags[mjRND_TEXTDIST] = 1;       // Text distance
opt.renderflags[mjRND_EYEBALL] = 1;        // Eyeballs
opt.renderflags[mjRND_HEADLIGHT] = 1;      // Headlight
```

## Off-Screen Rendering

```c
// Create framebuffer for off-screen rendering
int width = 1920, height = 1080;
unsigned char* rgb = (unsigned char*)malloc(3 * width * height);
unsigned char* depth = (unsigned char*)malloc(width * height * 4);

mjr_image rgb_image;
rgb_image.data = rgb;
rgb_image.width = width;
rgb_image.height = height;
rgb_image.type = mjtImgType::mjtImg_RGB;
rgb_image.stride = 3 * width;

mjr_image depth_image;
depth_image.data = depth;
depth_image.width = width;
depth_image.height = height;
depth_image.type = mjtImgType::mjtImg_Depth;
depth_image.stride = 4 * width;

// Render to images
mjr_readPixels(rgb, depth, &viewport, &con);
```

## Custom Visualization Geoms

```c
// Add custom visualization geoms
mjvGeom* geom = &scene.geoms[scene.ngeom++];
mjv_initGeom(geom, mjGEOM_ARROW, 0.1, NULL, NULL, color);
memcpy(geom->pos, position, sizeof(double) * 3);
memcpy(geom->mat, orientation, sizeof(double) * 9);
```
