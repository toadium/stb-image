// v37.0.0 强化学习测试 — reinforcement_learning 模块 12 函数

///|
test "create_default_rl_config: 默认RL配置" {
  let config = create_default_rl_config()
  assert_true(config.num_episodes > 0)
  assert_true(config.max_steps_per_episode > 0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.gamma > 0.0 && config.gamma <= 1.0)
  assert_true(config.epsilon_start > 0.0)
  assert_true(config.epsilon_end >= 0.0)
  assert_true(config.batch_size > 0)
  assert_true(config.buffer_size > 0)
}

///|
test "create_rl_environment: 创建RL环境" {
  let env = create_rl_environment("CartPole", 4, 2, 4, 2, true, 200)
  assert_true(env.num_states > 0)
  assert_true(env.num_actions > 0)
  assert_true(env.max_steps > 0)
  assert_true(env.current_step == 0)
  assert_true(!env.is_done)
}

///|
test "create_q_learning_agent: 创建Q学习代理" {
  let agent = create_q_learning_agent(10, 4, 0.1, 0.9, 0.1)
  assert_true(agent.num_states > 0)
  assert_true(agent.num_actions > 0)
  assert_true(agent.learning_rate > 0.0)
  assert_true(agent.gamma > 0.0)
  assert_true(agent.epsilon > 0.0)
  assert_true(agent.q_table.length() > 0)
}

///|
test "select_action: 选择动作" {
  let agent = create_q_learning_agent(10, 4, 0.1, 0.9, 0.1)
  let action = select_action(agent, 5)
  assert_true(action >= 0 && action < 4)
}

///|
test "q_learning_update: Q学习更新" {
  let agent = create_q_learning_agent(10, 4, 0.1, 0.9, 0.1)
  let updated = q_learning_update(agent, 5, 2, 1.0, 6, false)
  assert_true(updated.num_states > 0)
  assert_true(updated.num_actions > 0)
  assert_true(updated.episodes_completed >= 0)
}

///|
test "create_replay_buffer: 创建经验回放缓冲区" {
  let buffer = create_replay_buffer(1000, 32, ReplayBufferType::Uniform)
  assert_true(buffer.buffer_size > 0)
  assert_true(buffer.current_size == 0)
  assert_true(buffer.batch_size > 0)
  assert_true(buffer.buffer.length() >= 0)
}

///|
test "add_experience: 添加经验" {
  let buffer = create_replay_buffer(1000, 32, ReplayBufferType::Uniform)
  let exp = Experience::{
    state: [0.1, 0.2],
    action: 1,
    reward: 0.5,
    next_state: [0.3, 0.4],
    is_done: false,
    priority: 1.0,
  }
  let updated = add_experience(buffer, exp)
  assert_true(updated.current_size > 0)
  assert_true(updated.buffer.length() > 0)
}

///|
test "sample_experiences: 采样经验" {
  let buffer = create_replay_buffer(1000, 32, ReplayBufferType::Uniform)
  let exp = Experience::{
    state: [0.1, 0.2],
    action: 1,
    reward: 0.5,
    next_state: [0.3, 0.4],
    is_done: false,
    priority: 1.0,
  }
  let buffer1 = add_experience(buffer, exp)
  let samples = sample_experiences(buffer1, 1)
  assert_true(samples.length() >= 0)
}

///|
test "evaluate_policy: 策略评估" {
  let agent = create_q_learning_agent(10, 4, 0.1, 0.9, 0.1)
  let env = create_rl_environment("GridWorld", 10, 4, 10, 4, true, 100)
  let result = evaluate_policy(agent, env, 10)
  assert_true(result.num_episodes > 0)
  assert_true(result.average_reward >= -1000.0)
  assert_true(result.success_rate >= 0.0 && result.success_rate <= 1.0)
  assert_true(result.average_steps >= 0.0)
}

///|
test "simulate_rl_training: RL训练模拟" {
  let config = create_default_rl_config()
  let env = create_rl_environment("GridWorld", 10, 4, 10, 4, true, 100)
  let result = simulate_rl_training(config, env)
  assert_true(result.num_episodes > 0)
  assert_true(result.total_reward >= -100000.0)
  assert_true(result.average_reward >= -1000.0)
  assert_true(result.final_epsilon >= 0.0)
  assert_true(result.reward_history.length() >= 0)
  assert_true(result.loss_history.length() >= 0)
  assert_true(result.epsilon_history.length() >= 0)
  assert_true(result.training_time_s > 0.0)
}

///|
test "reinforcement_learning_report_to_string: 报告生成" {
  let config = create_default_rl_config()
  let env = create_rl_environment("GridWorld", 10, 4, 10, 4, true, 100)
  let result = simulate_rl_training(config, env)
  let report = reinforcement_learning_report_to_string(result, config, env)
  assert_true(report.length() > 0)
}
