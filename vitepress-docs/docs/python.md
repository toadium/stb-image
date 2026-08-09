# Python Bindings

MuJoCo comes with native Python bindings developed in C++ using [pybind11](https://pybind11.readthedocs.io/).

## Installation

```bash
pip install mujoco
```

## Import

```python
import mujoco
import mujoco.viewer
```

## Basic Usage

```python
import mujoco

# Load model
model = mujoco.MjModel.from_xml_path('humanoid.xml')
data = mujoco.MjData(model)

# Run simulation
while data.time < 10:
    mujoco.mj_step(model, data)

# Access state
print(f"Body position: {data.body('torso').xpos}")
print(f"Joint velocity: {data.joint('hip').qvel}")
```

## Named Access

Most models assign names to objects. The Python bindings provide convenient named access:

```python
# Access by name
body = model.body('torso')
geom = model.geom('left_foot')
joint = model.joint('hip_joint')

# Access data by name
pos = data.body('torso').xpos
quat = data.body('torso').xquat
vel = data.joint('hip').qvel
```

## Interactive Viewer

### Managed Viewer

```python
import mujoco
import mujoco.viewer

model = mujoco.MjModel.from_xml_path('humanoid.xml')
data = mujoco.MjData(model)

# Managed viewer - blocks until closed
with mujoco.viewer.launch_passive(model, data) as viewer:
    while viewer.is_running():
        mujoco.mj_step(model, data)
        viewer.sync()
```

### Passive Viewer

```python
import mujoco
import mujoco.viewer
import time

model = mujoco.MjModel.from_xml_path('humanoid.xml')
data = mujoco.MjData(model)

with mujoco.viewer.launch_passive(model, data) as viewer:
    while viewer.is_running():
        step_start = time.time()
        
        # Apply controls
        data.ctrl[0] = 1.0
        
        # Step simulation
        mujoco.mj_step(model, data)
        
        # Sync with viewer
        viewer.sync()
        
        # Maintain real-time
        time_until_next_step = model.opt.timestep - (time.time() - step_start)
        if time_until_next_step > 0:
            time.sleep(time_until_next_step)
```

### Command Line Viewer

```bash
# Launch viewer with a model
python -m mujoco.viewer --mjcf=/path/to/model.xml

# Launch empty viewer
python -m mujoco.viewer
```

## Model Editing

```python
import mujoco

spec = mujoco.MjSpec()
spec.modelname = "my robot"

# Add a body
body = spec.worldbody.add_body(
    name='base',
    pos=[0, 0, 1],
    quat=[0, 1, 0, 0]
)

# Add a geom
body.add_geom(
    name='box',
    type=mujoco.mjtGeom.mjGEOM_BOX,
    size=[0.5, 0.5, 0.5],
    rgba=[1, 0, 0, 1]
)

# Add a joint
body.add_joint(
    name='prismatic',
    type=mujoco.mjtJoint.mjJNT_SLIDE,
    axis=[0, 0, 1],
    range=[0, 2]
)

# Compile
model = spec.compile()
```

## Rollout Module

```python
import mujoco
import mujoco.rollout as rollout
import numpy as np

model = mujoco.MjModel.from_xml_path('humanoid.xml')

# Prepare rollout data
initial_state = np.zeros(mujoco.mj_stateSize(model, mujoco.mjtState.mjSTATE_FULLPHYSICS))
controls = np.zeros((100, model.nu))  # 100 steps of zero control

# Run rollout
states, sensordata = rollout.rollout(model, initial_state, controls)
```

## VFS (Virtual File System)

```python
import mujoco

# Using MjVfs
with mujoco.MjVfs() as vfs:
    vfs['model.xml'] = b'<mujoco><worldbody><body><geom size="1"/></body></worldbody></mujoco>'
    model = mujoco.MjModel.from_xml_string('model.xml', vfs=vfs)
```

## Error Handling

```python
import mujoco

try:
    model = mujoco.MjModel.from_xml_path('invalid.xml')
except mujoco.FatalError as e:
    print(f"Fatal error: {e}")
```
