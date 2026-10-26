kubectl patch deployment ucbe-0 --patch '
spec:
  template:
    spec:
      initContainers:
      - name: fetch-jmx-agent
        image: curlimages/curl:latest
        imagePullPolicy: Always
        command:
        - sh
        - -c
        - |
          curl -sLS https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar -o /jmx/jmx_prometheus_javaagent.jar
        volumeMounts:
        - name: jmx-shared
          mountPath: /jmx
      containers:
      - name: ucbe
        env:
        - name: JAVA_TOOL_OPTIONS
          value: "-javaagent:/jmx/jmx_prometheus_javaagent.jar=9404:/jmx/config.yaml"
        ports:
        - containerPort: 9404
          name: jmx-metrics
          protocol: TCP
        volumeMounts:
        - name: jmx-shared
          mountPath: /jmx
        - name: jmx-config
          mountPath: /jmx/config.yaml
          subPath: config.yaml
      volumes:
      - name: jmx-shared
        emptyDir: {}
      - name: jmx-config
        configMap:
          name: jmx-exporter-config
'
