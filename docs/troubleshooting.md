# Troubleshooting Guide

This guide answers common production troubleshooting questions for a Docker, EKS, Terraform, and CI/CD based application. The goal is to check the basics first, then move deeper without guessing.

## 1. Pod is in CrashLoopBackOff. What do you check?

- Check logs with `kubectl logs <pod-name> -n <namespace> --previous`.
- Describe the pod with `kubectl describe pod <pod-name> -n <namespace>` and look at events.
- Confirm the image starts correctly, required environment variables exist, and secrets/config maps are mounted.
- Check application errors, wrong command/entrypoint, missing files, database connection failure, or permission issues.
- Check resource limits. The pod may be crashing because it is out of memory.

## 2. Deployment is successful, but app is not reachable. What do you check?

- Check pods are running and ready: `kubectl get pods -n <namespace>`.
- Check the Service selector matches the pod labels.
- Check Service port and targetPort are correct.
- Check Ingress rules, hostname, path, certificate, and load balancer status.
- Check security groups, network ACLs, firewall rules, and DNS.
- Test inside the cluster using a temporary pod to separate app issues from ingress/network issues.

## 3. Difference between readiness and liveness probe?

- Readiness probe decides whether a pod should receive traffic.
- Liveness probe decides whether Kubernetes should restart the container.
- If readiness fails, the pod stays alive but is removed from Service endpoints.
- If liveness fails, Kubernetes restarts the container.
- Readiness should check whether the app is ready to serve. Liveness should check whether the process is still healthy.

## 4. Docker build works locally but fails in pipeline. Why?

- Local machine may have cached files, dependencies, or environment variables that the pipeline does not have.
- `.dockerignore` may exclude files needed during CI build.
- Dockerfile may rely on local-only paths or secrets.
- CI runner may use a different CPU architecture, Docker version, or base image state.
- Private package registries may require credentials that are missing in GitHub Actions.

## 5. Pipeline fails during Docker build. What do you check?

- Check the exact failing Docker layer in the pipeline logs.
- Confirm Dockerfile paths and build context are correct.
- Confirm required files are committed to GitHub.
- Check dependency install failures, package registry access, and network errors.
- Check base image availability and tag correctness.
- Check whether secrets or build args are required but not configured in the workflow.

## 6. Certificate renewal failed. What do you check?

- Check certificate issuer logs, such as cert-manager logs if cert-manager is used.
- Check DNS records point to the correct load balancer.
- Check HTTP-01 or DNS-01 challenge status.
- Check the Ingress annotation and TLS secret name.
- Check whether the domain is publicly reachable.
- Check rate limits from the certificate authority.
- Check IAM permissions if DNS validation updates records automatically.

## 7. Ingress returns 502 or 504. What do you check?

- Check backend pods are healthy and ready.
- Check Service endpoints: `kubectl get endpoints -n <namespace>`.
- Check targetPort matches the application container port.
- Check ALB or ingress controller logs/events.
- Check app response time, timeout settings, and health check path.
- Check security groups between load balancer and worker nodes/pods.
- For 502, suspect bad upstream response or no healthy target. For 504, suspect timeout or network path issue.

## 8. Vendor SFTP connection to port 22 times out. What do you check?

- Confirm the SFTP server is running and listening on port 22.
- Check security groups, firewall rules, network ACLs, and route tables.
- Confirm the vendor source IP is allowlisted.
- Check whether the SFTP endpoint is public or private and whether the vendor can reach that network.
- Check DNS resolution from the vendor side.
- Check server logs for rejected connections or authentication attempts.
- If hosted behind a VPN or private link, check tunnel status and routing.

## 9. Terraform plan wants to recreate the cluster. What do you check?

- Check which exact argument forces replacement in the Terraform plan.
- Check provider version changes and module changes.
- Check whether cluster name, VPC/subnet IDs, encryption config, authentication mode, or network settings changed.
- Check Terraform state is correct and using the expected backend/workspace.
- Check whether someone changed infrastructure manually outside Terraform.
- Do not apply until the replacement reason is understood and reviewed.

## 10. How would you upgrade AKS/EKS safely?

- Read the cloud provider release notes and compatibility notes.
- Upgrade one version at a time where required.
- Test the upgrade in a staging cluster first.
- Check add-ons, ingress controller, CNI, CSI drivers, autoscaler, and workloads.
- Upgrade the control plane first, then node groups.
- Use rolling node replacement with PodDisruptionBudgets.
- Monitor app health, cluster events, and rollback options during the upgrade.

## 11. Frontend loads, but backend API calls fail. What do you check?

- Check browser console and network tab for status code, CORS, mixed content, or DNS errors.
- Check the frontend API base URL.
- Check backend Ingress or Service route.
- Check backend pod logs.
- Check whether HTTPS frontend is calling HTTP backend, which browsers may block.
- Check CORS configuration if frontend and backend use different domains.

## 12. Backend pod is running, but database connection times out. What do you check?

- Check database hostname, port, username, database name, and secret values.
- Check security group rules from EKS nodes/pods to the database.
- Check database subnet routing and whether it is private/public as expected.
- Check network policies in Kubernetes.
- Check database availability, max connections, and logs.
- Test connectivity from inside the cluster using a temporary debug pod.

## 13. Private DNS is not resolving database hostname. What do you check?

- Check VPC DNS support and DNS hostnames are enabled.
- Check the pod/node VPC resolver can resolve private records.
- Check Route 53 private hosted zone association with the correct VPC.
- Check CoreDNS pods and logs in the cluster.
- Check whether the hostname belongs to the correct region/account/VPC.
- Test with `nslookup` or `dig` from inside a pod.

## 14. How would you rotate database credentials safely?

- Create a new database user or password first.
- Store the new value in Secrets Manager, External Secrets, or Kubernetes Secret.
- Update the application to use the new secret.
- Restart or roll out backend pods gradually.
- Verify new connections are successful.
- Remove or disable old credentials only after the new deployment is stable.
- Keep a rollback window in case the new secret is wrong.

## 15. Secrets were accidentally committed to GitHub. What do you do?

- Treat the secret as compromised immediately.
- Revoke or rotate the secret in the source system.
- Remove the secret from the repository and commit the cleanup.
- If needed, rewrite Git history and force push, but do not rely on history cleanup as the only fix.
- Check GitHub secret scanning alerts and audit logs.
- Review access logs for suspicious usage.
- Add prevention: `.gitignore`, secret scanning, pre-commit hooks, and least-privilege credentials.
