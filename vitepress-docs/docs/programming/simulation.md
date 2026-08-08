# Simulation

This chapter covers MuJoCo simulation programming.

## Basic Simulation

The top-level API function is `mj_step`:

```c
void mj_step(const mjModel* m, mjData* d);
```

### Full Simulation Loop

```c
#include "mujoco.h"
#include <stdio.h>

int main(int argc, char** argv) {
  char error[1000];
  
  // Load model
  mjModel* m = mj_loadXML("model.xml", NULL, error, 1000);
  if (!m) {
    printf("Load error: %s\n", error);
    return 1;
  }
  
  // Allocate data
  mjData* d = mj_makeData(m);
  if (!d) {
    printf("Data allocation failed\n");
    mj_deleteModel(m);
    return 1;
  }
  
  // Simulation loop
  int nstep = 1000;
  for (int i = 0; i < nstep; i++) {
    mj_step(m, d);
  }
  
  printf("Final time: %.3f\n", d->time);
  
  // Cleanup
  mj_deleteData(d);
  mj_deleteModel(m);
  
  return 0;
}
```

## State and Control

### State Management

```c
// Set state to keyframe
mj_resetDataKeyframe(m, d, keyframe_id);

// Reset all data
mj_resetData(m, d);

// Get/set state
mj_getState(m, d, state, mjSTATE_FULLPHYSICS);
mj_setState(m, d, state, mjSTATE_FULLPHYSICS);
```

### Input

```c
// Apply control
d->ctrl[0] = 1.0;    // Set control for actuator 0
d->ctrl[1] = -0.5;   // Set control for actuator 1

// Apply external force
d->xfrc_applied[6*i]     = fx;    // Force x
d->xfrc_applied[6*i+1]   = fy;    // Force y
d->xfrc_applied[6*i+2]   = fz;    // Force z
d->xfrc_applied[6*i+3]   = tx;    // Torque x
d->xfrc_applied[6*i+4]   = ty;    // Torque y
d->xfrc_applied[6*i+5]   = tz;    // Torque z
```

## Multi-Threading

MuJoCo supports multi-threaded simulation for parallel sampling:

```c
// Create multiple data instances sharing the same model
mjData* d1 = mj_makeData(m);
mjData* d2 = mj_makeData(m);

// Run simulations in parallel
#pragma omp parallel
{
  int thread_id = omp_get_thread_num();
  mjData* d = (thread_id == 0) ? d1 : d2;
  
  while (d->time < 10.0) {
    mj_step(m, d);
  }
}

mj_deleteData(d1);
mj_deleteData(d2);
```

## Callbacks

Users can install custom callbacks to modify computation:

```c
// Custom control callback
void my_control_callback(const mjModel* m, mjData* d) {
  // Implement custom control logic
  d->ctrl[0] = sin(d->time);
}

// Install callback
mjcb_control = my_control_callback;

// Custom sensor callback
void my_sensor_callback(const mjModel* m, mjData* d) {
  // Add custom sensor data
  d->sensordata[0] = d->time * d->time;
}

mjcb_sensor = my_sensor_callback;
```

## Common Operations

### Accessing Body State

```c
// Body position and orientation
printf("Body pos: %.3f %.3f %.3f\n", 
       d->body_xpos[0], d->body_xpos[1], d->body_xpos[2]);
printf("Body quat: %.3f %.3f %.3f %.3f\n",
       d->body_xquat[0], d->body_xquat[1], 
       d->body_xquat[2], d->body_xquat[3]);

// Body velocity
printf("Linear vel: %.3f %.3f %.3f\n",
       d->body_xvelp[0], d->body_xvelp[1], d->body_xvelp[2]);
printf("Ang. vel: %.3f %.3f %.3f\n",
       d->body_xvelr[0], d->body_xvelr[1], d->body_xvelr[2]);
```

### Accessing Joint State

```c
// Joint positions and velocities
for (int i = 0; i < m->njnt; i++) {
  printf("Joint %d: qpos[0] = %.3f, qvel[0] = %.3f\n",
         i, d->qpos[m->jnt_qposadr[i]],
         d->qvel[m->jnt_dofadr[i]]);
}
```

### Accessing Geom State

```c
// Geom position and orientation
for (int i = 0; i < m->ngeom; i++) {
  printf("Geom %d: pos = %.3f %.3f %.3f\n",
         i, d->geom_xpos[3*i], d->geom_xpos[3*i+1], d->geom_xpos[3*i+2]);
}
```
