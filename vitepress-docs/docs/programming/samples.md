---
layout: page
---

# Code Samples

This page lists the code samples included with MuJoCo.

## C/C++ Samples

### simulate.cc

The full-featured interactive simulator. See [Visualization](/programming/visualization.md) for details.

### test_speed.cc

Benchmark tool for measuring simulation performance.

```bash
./test_speed model.xml
```

### test_render.cc

Off-screen rendering benchmark.

```bash
./test_render model.xml --width=1920 --height=1080
```

### example.cc

Minimal simulation example:

```c
#include "mujoco.h"
#include "stdio.h"

int main(void) {
  char error[1000];
  mjModel* m = mj_loadXML("hello.xml", NULL, error, 1000);
  if (!m) { printf("%s\n", error); return 1; }

  mjData* d = mj_makeData(m);
  while (d->time < 10) mj_step(m, d);
  mj_deleteData(d);
  mj_deleteModel(m);
  return 0;
}
```

## Python Samples

### hello_mujoco.py

```python
import mujoco

model = mujoco.MjModel.from_xml_path('model/humanoid/humanoid.xml')
data = mujoco.MjData(model)

while data.time < 10:
    mujoco.mj_step(model, data)
    print(f"Time: {data.time:.2f}s, Height: {data.body('torso').xpos[2]:.2f}m")
```

### viewer_example.py

```python
import mujoco
import mujoco.viewer

model = mujoco.MjModel.from_xml_path('model/humanoid/humanoid.xml')
data = mujoco.MjData(model)

with mujoco.viewer.launch_passive(model, data) as viewer:
    while viewer.is_running():
        mujoco.mj_step(model, data)
        viewer.sync()
```

## MJX Samples

### mjx_hello.py

```python
import jax
import mujoco
from mujoco import mjx

model = mujoco.MjModel.from_xml_string("""
<mujoco>
  <worldbody>
    <body>
      <freejoint/>
      <geom size=".15" mass="1" type="sphere"/>
    </body>
  </worldbody>
</mujoco>
""")

mjx_model = mjx.put_model(model)

@jax.vmap
def step(vel):
    data = mjx.make_data(mjx_model)
    data = data.replace(qvel=data.qvel.at[0].set(vel))
    return mjx.step(mjx_model, data).qpos[0]

result = jax.jit(step)(jax.numpy.array([0.5, 0.7, 0.9]))
print(result)
```
