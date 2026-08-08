# MuJoCo Warp

MuJoCo Warp is a GPU-accelerated implementation of MuJoCo using [NVIDIA Warp](https://nvidia.github.io/warp/).

## Overview

MuJoCo Warp provides:
- Full feature parity with the C engine
- Hardware-accelerated simulation on NVIDIA GPUs
- MJX integration for JAX workflows
- Batch rendering for multi-camera setups

## Installation

```bash
pip install mujoco-mjx[warp]
```

## Basic Usage

```python
import mujoco
from mujoco import mjx

# Load model
mjm = mujoco.MjModel.from_xml_path("humanoid.xml")

# Create MJX model with Warp backend
model = mjx.put_model(mjm, impl='warp')

# Create data
data = mjx.make_data(model, impl='warp', naconmax=10000, njmax=1000)

# Step simulation
data = mjx.step(model, data)
```

## Graph Modes

MJX-Warp supports different CUDA graph capture modes:

| Mode | Description | Use Case |
|------|-------------|----------|
| `JAX` | No CUDA graph capture | Debugging |
| `WARP` | Default capture mode | General use |
| `WARP_STAGED` | Staging buffers for stable pointers | Performance-critical |
| `WARP_STAGED_EX` | External copy operations | Maximum stability |

```python
import mujoco.mjx.warp as mjxw

model = mjx.put_model(mjm, impl='warp', graph_mode=mjxw.GraphMode.WARP_STAGED)
```

## Batch Rendering

```python
from mujoco.mjx import create_render_context, get_rgb

# Create render context
rc = create_render_context(
    mjm=mjm,
    nworld=100,
    cam_res=(640, 480),
    use_textures=True,
    use_shadows=True,
    render_rgb=[True] * 4,
    render_depth=[False] * 4,
)

@jax.jit
def render_fn(mx, d, rc_pytree):
    d = mjx.refit_bvh(mx, d, rc_pytree)
    pixels, _ = mjx.render(mx, d, rc_pytree)
    rgb = get_rgb(rc_pytree, 0, pixels)
    return rgb, d
```

## Multi-GPU with pmap

```python
import jax

ndevices = jax.local_device_count()
nworld_per_device = nworld // ndevices

rc = create_render_context(
    mjm=m,
    nworld=nworld_per_device,
    devices=[f'cuda:{i}' for i in range(ndevices)],
    cam_res=(640, 480),
)
```

## Performance Tips

1. **Tune naconmax and njmax**: Start with conservative values and increase as needed
2. **Use WARP_STAGED**: Avoid excessive CUDA graph recaptures
3. **Enable batch rendering**: For observation-based workloads
4. **Profile with testspeed**: Use the built-in benchmarking tool
