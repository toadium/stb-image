# MuJoCo XLA (MJX)

MuJoCo XLA (MJX) provides a [JAX](https://github.com/jax-ml/jax#readme) API for various implementations of MuJoCo. MJX can run on all compute hardware supported by the [XLA](https://www.tensorflow.org/xla) compiler.

## Installation

```bash
# Basic installation
pip install mujoco-mjx

# With Warp support (NVIDIA GPUs)
pip install mujoco-mjx[warp]
```

## Minimal Example

```python
import jax
import mujoco
from mujoco import mjx

XML = """
<mujoco>
  <worldbody>
    <body>
      <freejoint/>
      <geom size=".15" mass="1" type="sphere"/>
    </body>
  </worldbody>
</mujoco>
"""

model = mujoco.MjModel.from_xml_string(XML)
mjx_model = mjx.put_model(model)

@jax.vmap
def batched_step(vel):
    mjx_data = mjx.make_data(mjx_model)
    qvel = mjx_data.qvel.at[0].set(vel)
    mjx_data = mjx_data.replace(qvel=qvel)
    pos = mjx.step(mjx_model, mjx_data).qpos[0]
    return pos

vel = jax.numpy.arange(0.0, 1.0, 0.01)
pos = jax.jit(batched_step)(vel)
print(pos)
```

## Implementations

### MJX-JAX

A pure JAX re-implementation of MuJoCo. Supports:
- Nvidia GPUs
- AMD GPUs
- Apple Silicon
- Google Cloud TPUs

**Key features:**
- Automatic differentiation (for most operations)
- JIT compilation
- VMAP for parallel simulation

### MJX-Warp

Uses [MuJoCo Warp](./mjwarp/index.md) for NVIDIA GPU acceleration.

**Key features:**
- Resolves performance bottlenecks in MJX-JAX
- Full mesh collision support
- Batch rendering

## Feature Comparison

| Feature | MJX-JAX | MJX-Warp |
|---------|---------|----------|
| Differentiability | ✅ | ❌ |
| Mesh collisions | ⚠️ Limited | ✅ Full |
| Flex | ❌ | ✅ |
| Fluid forces | ⚠️ Inertia only | ✅ Full |
| Sensors | ⚠️ Partial | ✅ Full |
| Solvers | NEWTON, CG | NEWTON, CG, PGS |

## Performance Tuning

### MJX-JAX Tips

1. **Reduce solver iterations**: Set `iterations=1` and `ls_iterations=1`
2. **Use explicit contacts**: Mark geom pairs for collision detection
3. **Limit mesh vertices**: Set `maxhullvert="64"` for meshes
4. **Disable eulerdamp**: `option flag eulerdamp="false"`
5. **Choose jacobian format**: Dense for GPU, sparse for TPU

### GPU Performance

```bash
# Enable Triton GEMM for NVIDIA GPUs
export XLA_FLAGS="--xla_gpu_triton_gemm_any=true"
```

## Command Line Tools

```bash
# Test simulation speed
mjx-testspeed --mjcf=/path/to/model.xml

# Launch interactive viewer
mjx-viewer --mjcf=/path/to/model.xml
```

## Tutorial

A comprehensive tutorial notebook is available:
[![colab](https://colab.research.google.com/assets/colab-badge.png)](https://colab.research.google.com/github/google-deepmind/mujoco/blob/main/mjx/tutorial.ipynb)
