#include "wingii.h"
#include "vendor/node/bin/include/node_embedding_api.h"

#include <vector>
#include <string>
#include <memory>
#include <cstring>
#include <cassert>
#include <iostream>

namespace
{
  static const char *script{nullptr};
  static napi_value napi_entry(napi_env env, napi_value exports)
  {
    if (!script)
    {
      std::cerr << "No script provided." << std::endl;
      return nullptr;
    }
    napi_value script_string;
    if (napi_ok != napi_create_string_utf8(env,
                                           script,
                                           std::strlen(script),
                                           &script_string))
    {
      std::cerr << "napi_create_string_utf8 failed." << std::endl;
      return nullptr;
    }

    napi_value result;
    if (napi_ok != napi_run_script(env, script_string, &result))
    {
      std::cerr << "napi_run_script failed." << std::endl;
      return nullptr;
    }
    return nullptr;
  }
} // !namespace

extern "C"
{
  struct wingpf_call_prep_t_
  {
    const char *program;
    const char *context;
    wingpf_engine_type_t type;
  };
  wingpf_call_prep_t *wingpf_prep(wingpf_engine_type_t const type)
  {
    return new wingpf_call_prep_t_{nullptr, nullptr, type};
  }
  void wingpf_set_program(wingpf_call_prep_t *const instance, const char *const program)
  {
    assert(instance);
    if (instance->program == program)
      return;
    instance->program = program;
  }
  void wingpf_set_context(wingpf_call_prep_t *const instance, const char *const context)
  {
    assert(instance);
    if (instance->context == context)
      return;
    instance->context = context;
  }
  int wingpf_call(const wingpf_call_prep_t *const instance)
  {
    assert(instance);
    assert(instance->program);
    assert(instance->context);

    std::vector<std::string> arguments;
    std::vector<char *> argv;

    for (const auto &arg : arguments)
      argv.push_back((char *)arg.data());
    argv.push_back(nullptr);
    const auto argc = argv.size() - 1;

    script = instance->program;
    node_options_t options{static_cast<int>(argc), argv.data(), napi_entry};
    const auto ret = node_run(options);
    if (ret.exit_code != 0)
    {
      std::cerr << "program exited with non-zero code: " << ret.exit_code << std::endl;
      if (ret.error != nullptr)
      {
        std::shared_ptr<char> error_message{ret.error};
        std::cerr << "error message: " << std::string(error_message.get()) << std::endl;
      }
    }
    return ret.exit_code;
  }
  void wingpf_free(wingpf_call_prep_t *const instance)
  {
    if (!instance)
      return;
    delete instance;
  }
}
