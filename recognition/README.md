# Activity Recognition Using Kernel Cross-Correlator (KCC)

This part requires the following WARD 1.0 dataset:

    https://people.eecs.berkeley.edu/~yang/software/WAR/index.html

However, you may also measure the similarity of any signals.
For example, you may use it as:

	   lambda = 0.1
	   sigma = 0.2
	   x = randn(10)
	   y = randn(10)
	   z = randn(10)

       correlator = kcc_train(x, lambda, sigma);

       similarity_xy = kcc(y, correlator);
       similarity_xz = kcc(z, correlator);


