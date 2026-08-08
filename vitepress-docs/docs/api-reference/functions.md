# API Reference

## Main Simulation Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_step` | `void mj_step(const mjModel\* m, mjData\* d)` | Advance simulation by one timestep |
| `mj_forward` | `void mj_forward(const mjModel\* m, mjData\* d)` | Compute forward dynamics |
| `mj_inverse` | `void mj_inverse(const mjModel\* m, mjData\* d)` | Compute inverse dynamics |
| `mj_transition` | `void mj_transition(const mjModel\* m, const mjData\* d, const mjData\* u, mjData\* dnext)` | Compute state transition |
| `mj_transitionfd` | `void mj_transitionfd(const mjModel\* m, const mjData\* d, const mjData\* u, mjData\* dnext)` | Compute finite-difference transition |

## Model Management

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_loadXML` | `mjModel\* mj_loadXML(const char\* xmlpath, const char\* assetpath, char\* error, int error_sz)` | Load model from XML |
| `mj_loadModel` | `mjModel\* mj_loadModel(const char\* modelpath, char\* error, int error_sz)` | Load model from file |
| `mj_deleteModel` | `void mj_deleteModel(mjModel\* m)` | Free model |
| `mj_compile` | `mjModel\* mj_compile(mjSpec\* spec, char\* error, int error_sz)` | Compile mjSpec to mjModel |

## Data Management

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_makeData` | `mjData\* mj_makeData(const mjModel\* m)` | Allocate mjData |
| `mj_deleteData` | `void mj_deleteData(mjData\* d)` | Free mjData |
| `mj_resetData` | `void mj_resetData(const mjModel\* m, mjData\* d)` | Reset data to defaults |
| `mj_resetDataKeyframe` | `void mj_resetDataKeyframe(const mjModel\* m, mjData\* d, int keyframe)` | Reset to keyframe |

## State Management

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_getState` | `void mj_getState(const mjModel\* m, const mjData\* d, mjState\* state, mjtState stateflags)` | Get state |
| `mj_setState` | `void mj_setState(mjModel\* m, mjData\* d, const mjState\* state, mjtState stateflags)` | Set state |
| `mj_stateSize` | `int mj_stateSize(const mjModel\* m, mjtState stateflags)` | Get state vector size |

## Kinematics

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_forwardPosition` | `void mj_forwardPosition(const mjModel\* m, mjData\* d)` | Forward kinematics |
| `mj_forwardVelocity` | `void mj_forwardVelocity(const mjModel\* m, mjData\* d)` | Forward velocity |
| `mj_forwardAcceleration` | `void mj_forwardAcceleration(const mjModel\* m, mjData\* d)` | Forward acceleration |
| `mj_forwardForce` | `void mj_forwardForce(const mjModel\* m, mjData\* d)` | Forward force |
| `mj_inverseDynamics` | `void mj_inverseDynamics(const mjModel\* m, mjData\* d)` | Inverse dynamics |
| `mj_inverseDynamicsCorrection` | `void mj_inverseDynamicsCorrection(const mjModel\* m, mjData\* d)` | Inverse dynamics with correction |

## Geometry Queries

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_distanceGeom` | `void mj_distanceGeom(const mjModel\* m, const mjData\* d, mjvGeom\* geom1, mjvGeom\* geom2, mjtDistance\* dist)` | Compute geom distance |
| `mj_geomsAabb` | `void mj_geomsAabb(const mjModel\* m, const mjData\* d, mjtByte\* flags, double\* aabb)` | Compute axis-aligned bounding boxes |
| `mj_collideGeoms` | `void mj_collideGeoms(const mjModel\* m, const mjData\* d, const mjGeom\* geom1, const mjGeom\* geom2, mjtContact\* contact)` | Compute collision between two geoms |

## Sensing

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_sensorPos` | `void mj_sensorPos(const mjModel\* m, mjData\* d)` | Compute positions |
| `mj_sensorVel` | `void mj_sensorVel(const mjModel\* m, mjData\* d)` | Compute velocities |
| `mj_sensorAcc` | `void mj_sensorAcc(const mjModel\* m, mjData\* d)` | Compute accelerations |
| `mj_sensorForce` | `void mj_sensorForce(const mjModel\* m, mjData\* d)` | Compute forces |

## Rendering

| Function | Signature | Description |
|----------|-----------|-------------|
| `mjv_makeScene` | `void mjv_makeScene(const mjModel\* m, mjvScene\* scene, int maxgeom)` | Create scene |
| `mjv_freeScene` | `void mjv_freeScene(mjvScene\* scene)` | Free scene |
| `mjv_updateScene` | `void mjv_updateScene(const mjModel\* m, mjData\* d, const mjvOption\* opt, const mjvPerturb\* pert, mjvCamera\* cam, mjtCatBit category)` | Update scene |
| `mjr_render` | `void mjr_render(mjrRect rect, const mjvScene\* scene, const mjrContext\* ctx)` | Render scene |
| `mjr_readPixels` | `void mjr_readPixels(unsigned char\* rgb, unsigned char\* depth, mjrRect rect, const mjrContext\* ctx)` | Read pixels |

## Utility Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `mj_name2id` | `int mj_name2id(const mjModel\* m, mjtObj type, const char\* name)` | Get ID from name |
| `mj_id2name` | `const char\* mj_id2name(const mjModel\* m, mjtObj type, int id)` | Get name from ID |
| `mj_differentiatePos` | `void mj_differentiatePos(double\* v, const mjModel\* m, const double\* q0, const double\* q1)` | Differentiate positions |
| `mj_integratePos` | `void mj_integratePos(double\* qnew, const mjModel\* m, const double\* q, const double\* v, double dt)` | Integrate positions |
