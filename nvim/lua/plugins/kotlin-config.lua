require("kotlin").setup({
  ft = { "kotlin" },
  root_markers = {
    "gradlew",
    ".git",
    "mvnw",
    "settings.gradle",
  },
  -- jre_path = "/Library/Java/JavaVirtualMachines/temurin-26.jdk/Contents/Home",
  -- jdk_for_symbol_resolution = "/Library/Java/JavaVirtualMachines/temurin-26.jdk/Contents/Home",
  jvm_args = {
    "-Xmx2g",
    "-XX\\:MetaspaceSize\\=512M",
    "-XX\\:MaxMetaspaceSize\\=512M",
    "-XX\\:+HeapDumpOnOutOfMemoryError",
    "-Dfile.encoding\\=UTF-8",
  },
})
