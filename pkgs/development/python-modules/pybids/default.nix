{ buildPythonPackage
, lib
, fetchPypi
, fetchpatch
, formulaic
, click
, num2words
, numpy
, scipy
, pandas
, nibabel
, patsy
, bids-validator
, sqlalchemy
, pytestCheckHook
, versioneer
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  version = "0.16.3";
  pname = "pybids";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-EOJ5NQyNFMpgLA1EaaXkv3/zk+hkPIMaVGrnNba4LMM=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  pythonRelaxDeps = [ "sqlalchemy" ];

  propagatedBuildInputs = [
    click
    formulaic
    num2words
    numpy
    scipy
    pandas
    nibabel
    patsy
    bids-validator
    sqlalchemy
    versioneer
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "bids" ];
  # looks for missing data:
  disabledTests = [ "test_config_filename" ];

  meta = with lib; {
    description = "Python tools for querying and manipulating BIDS datasets";
    homepage = "https://github.com/bids-standard/pybids";
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };
}
