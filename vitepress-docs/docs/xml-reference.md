# XML Reference

This chapter documents the MuJoCo XML schema (MJCF) in detail.

## Root Element

```xml
<mujoco model="name" compiler="auto" angle="radian" version="1.0">
  <!-- ... -->
</mujoco>
```

| Attribute | Default | Description |
|-----------|---------|-------------|
| `model` | | Model name |
| `compiler` | `auto` | Compiler settings |
| `angle` | `radian` | Angle unit: `radian` or `degree` |
| `version` | `1.0` | MuJoCo version |

## Scene Hierarchy

```
<mujoco>
  <compiler .../>
  <option .../>
  <default .../>
  <asset .../>
  <size .../>
  <equality .../>
  <actuator .../>
  <sensor .../>
  <worldbody>
    <body .../>
  </worldbody>
  <tendon>
    <!-- ... -->
  </tendon>
</mujoco>
```

## Option

```xml
<option timestep="0.002"
        gravity="0 0 -9.81"
        integrator="EULER"
        solver="NEWTON"
        iterations="1"
        ls_iterations="4"
        jacobian="dense"
        cone="pyramidal"
        enable="..."
        flag="..."/>
```

### Key Attributes

| Attribute | Values | Description |
|-----------|--------|-------------|
| `timestep` | float | Simulation timestep |
| `gravity` | 3 floats | Gravity vector |
| `integrator` | EULER, IMPLICITFAST, IMPLICIT, RK4 | Numerical integrator |
| `solver` | NEWTON, CG, PGS | Constraint solver |
| `iterations` | int | Solver iterations |
| `jacobian` | dense, sparse, auto | Jacobian format |
| `cone` | pyramidal, elliptic | Friction cone type |

## Default

The `<default>` element sets default attributes for all subsequent elements of the same type.

```xml
<default>
  <geom rgba=".8 .6 .4 1" condim="3"/>
  <joint damping="0.1"/>
  <tendon>
    <spatial width="0.005"/>
  </tendon>
</default>
```

## World Body

```xml
<worldbody>
  <body name="root" pos="0 0 0">
    <joint name="root_joint" type="free" pos="0 0 0"/>
    <geom name="body_geom" type="box" size="0.5 0.5 0.5" rgba="1 0 0 1"/>
    <body name="child" pos="1 0 0">
      <!-- nested bodies -->
    </body>
    <site name="site1" pos="0 0 0" size="0.01"/>
    <camera name="cam1" pos="0 0 1" euler="0 0 0"/>
    <light name="light1" pos="0 0 2" dir="0 0 -1"/>
  </body>
</worldbody>
```

## Joint Attributes

| Attribute | Description |
|-----------|-------------|
| `name` | Joint name |
| `type` | `free`, `ball`, `slide`, `hinge` |
| `pos` | Position offset from parent |
| `axis` | Joint axis (for hinge/slide) |
| `range` | Joint limits |
| `stiffness` | Spring stiffness |
| `springref` | Spring reference pose |
| `damping` | Damping coefficient |
| `ref` | Reference position |

## Geom Attributes

| Attribute | Description |
|-----------|-------------|
| `name` | Geom name |
| `type` | Shape type (see Geom Types) |
| `size` | Shape parameters |
| `pos` | Position relative to body |
| `quat` | Orientation as quaternion |
| `rgba` | Color (R G B A) |
| `material` | Material reference |
| `contype` | Collision type |
| `conaffinity` | Collision affinity |
| `group` | Rendering group |

## Tendon

```xml
<tendon>
  <fixed name="flexor" range="0 0.4">
    <joint joint="finger_joint" coeff="0.01"/>
  </fixed>
  <spatial name="tendon1" range="0 0.6" width="0.005">
    <site site="end1"/>
    <site site="end2"/>
  </spatial>
</tendon>
```

## Actuator

```xml
<actuator>
  <general name="actuator1"
           joint="joint1"
           gainprm="10"
           biasprm="0 -10 -0"/>
  <motor name="motor1"
         joint="joint1"
         ctrlrange="-1 1"
         forcerange="-10 10"/>
</actuator>
```

## Sensor

```xml
<sensor>
  <jointpos name="pos" joint="joint1"/>
  <jointvel name="vel" joint="joint1"/>
  <accelerometer name="acc" site="site1"/>
  <gyro name="gyro" site="site1"/>
  <touch name="touch" site="site1"/>
  <force name="force" site="site1"/>
  <framelinvel name="vel" frame="frame1"/>
</sensor>
```

## Equality

```xml
<equality>
  <connect name="pin" body1="body1" body2="body2" anchor="0 0 0"/>
  <weld name="weld" body1="body1" body2="body2" relpose="0 0 0 1 0 0 0"/>
  <joint name="fix" joint1="joint1" polycoef="0 0 0 0 0"/>
  <tendon name="fix_ten" tendon1="ten1" polycoef="0 0 0 0 0"/>
</equality>
```

## Keyframe

```xml
<keyframe>
  <key name="start"
       qpos="0 0 1 1 0 0 0 0 0 0 0 0"
       qvel="0 0 0 0 0 0 0 0 0 0 0 0"
       ctrl="0 0"/>
</keyframe>
```
