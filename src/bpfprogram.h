#pragma once

#include <cstdint>
#include <optional>
#include <string>
#include <tuple>
#include <unordered_map>
#include <vector>

namespace bpftrace {

using BpfBytecode = std::unordered_map<std::string, std::vector<uint8_t>>;

class BPFtrace;

class BpfProgram
{
public:
  static std::optional<BpfProgram> CreateFromBytecode(
      const BpfBytecode &bytecode,
      const std::string &name,
      BPFtrace &bpftrace);

  void assemble();

  const std::vector<uint8_t> &getCode();

  BpfProgram(const BpfProgram &) = delete;
  BpfProgram &operator=(const BpfProgram &) = delete;
  BpfProgram(BpfProgram &&) = default;
  BpfProgram &operator=(BpfProgram &&) = default;

private:
  explicit BpfProgram(const BpfBytecode &bytecode,
                      const std::string &name,
                      BPFtrace &bpftrace);


  const BpfBytecode &bytecode_;
  BPFtrace &bpftrace_;
  std::string name_;
  std::vector<uint8_t> code_;
};

} // namespace bpftrace
