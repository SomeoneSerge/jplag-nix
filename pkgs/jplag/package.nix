{
  lib,
  # stdenv,
  maven,
  fetchFromGitHub,
  # jdk11_headless,
  makeWrapper,
  jre,
  jre_headless,
  jreEffective ? if jplagEnableView then jre else jre_headless,
  jplagEnableView ? true, # Support --mode VIEW
}:

maven.buildMavenPackage rec {
  pname = "jplag";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "jplag";
    repo = "JPlag";
    rev = "v${version}";
    hash = "sha256-o7SEQHbvKigEMu3sPnk9r3rTk2viFNUo9TnowkENols=";
  };
  # nativeBuildInputs = [ jdk11_headless ];
  nativeBuildInputs = [ makeWrapper ];

  # no mvnParameters: mvnHash = "sha256-mhOZCRySZxEWESgyxkCpkjN0/T2HlesygCBDlK/RRuk=";
  mvnHash = "sha256-mnYd9fPA9TWmclMdD041ghUI6Nqie9kx6ZRBvIVm/NM=";
  mvnParameters = "assembly:single";
  installAllJars = true;
  makeWrapperArgs = [
    "--add-flags -Dorg.slf4j.simpleLogger.defaultLogLevel=INFO"
  ];
  installPhase = ''
    mkdir -p "$out/share/jplag"
    mkdir -p "$out/bin"
    if [[ "''${installAllJars:-}" ]] ; then
      find -iname '*.jar' -exec install -t "$out/share/jplag/" "{}" ";"
    else
      find -iname 'jplag*.jar' -exec install -t "$out/share/jplag/" "{}" ";"
      find -iname 'cli*.jar' -exec install -t "$out/share/jplag/" "{}" ";"
    fi

    local classPath=
    while IFS= read -r -d "" j ; do
      classPath="$classPath''${classPath:+:}$j"
    done < <( find "$out" -iname "*.jar" -print0 )
    flagsArray=(
      "${lib.getExe' jreEffective "java"}"
      "$out/bin/jplag"
    )
    concatTo flagsArray makeWrapperArgs
    flagsArray+=(
      --add-flags "-cp $classPath"
      --add-flags "de.jplag.cli.CLI"
    )
    makeWrapper "''${flagsArray[@]}"
       
  '';

  meta = {
    description = "State-of-the-Art Software Plagiarism & Collusion Detection";
    homepage = "git@github.com:jplag/JPlag.git";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
    mainProgram = "jplag";
    platforms = lib.platforms.all;
  };
}
