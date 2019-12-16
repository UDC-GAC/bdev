# Big Data Evaluator (BDEv)

[**Big Data Evaluator (BDEv)**](http://bdev.des.udc.es) is a benchmarking tool that allows to evaluate multiple Big Data processing frameworks (e.g., Hadoop, Spark, Flink) using different micro-benchmarks and real-world applications in order to obtain valuable information about their performance, resource utilization, energy efficiency and microarchitectural behaviour.

## Citation

If you use **BDEv** in your research, please cite our work using the following reference:

> Jorge Veiga, Jonatan Enes, Roberto R. Expósito and Juan Touriño. [BDEv 3.0: Energy efficiency and microarchitectural characterization of Big Data processing frameworks](https://doi.org/10.1016/j.future.2018.04.030). Future Generation Computer Systems 86: 565-581, 2018.

## Download

To download a specific version of BDEv, which is the preferred approach, you should clone a specific tag from the github repository instead of cloning the master branch. For example, to download version 3.3 you should execute:

```
git clone --branch v3.3 https://github.com/rreye/bdev.git
```

If you want to use the [BDWatchdog](http://bdwatchdog.dec.udc.es) framework for monitoring resource usage, which is integrated within BDEv a git submodule, you should use the following command instead:

```
git clone --branch v3.3 --recurse-submodules https://github.com/rreye/bdev.git
```

Further information about BDEv usage and configuration is provided in the user's guide available to download at http://bdev.des.udc.es.

## Authors

This tool is developed in the [Computer Architecture Group](http://gac.udc.es/english) at the [Universidade da Coruña](https://www.udc.es/en) by:

* **Jorge Veiga** (http://gac.udc.es/~jveiga)
* **Roberto R. Expósito** (http://gac.udc.es/~rober)
* **Jonatan Enes** (http://gac.udc.es/~jonatan)
* **Guillermo L. Taboada** (http://gac.udc.es/~gltaboada)
* **Juan Touriño** (http://gac.udc.es/~juan)

## License

This tool is distributed as free software and is publicly available under the MIT license (see the [LICENSE](LICENSE) file for more details)

