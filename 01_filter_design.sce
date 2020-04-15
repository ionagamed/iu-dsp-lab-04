%show_plots = 1

// Constants {{{1 ==============================================================

Fs = 44100;

// Investigation {{{1 ==========================================================

signal = loadwave('./01_data/signal_with_low_freq_noise_2.wav');
signal = signal(1, :);

if %show_plots then
  clf();
  plot(signal);
  xs2png(0, './01_plots/01_source_signal.png');
end

s_len = length(signal);
frequencies = (0 : s_len - 1) / s_len * Fs;
signal_freq = abs(fft(signal));

if %show_plots then
  clf();
  plot2d('nl', frequencies, signal_freq, color('blue'));
  xs2png(0, './01_plots/02_source_frequencies.png');
end

// FIR filter {{{1 =============================================================

// Band pass filter. Will let through frequencies from `low_freq` to `high_freq`
// @param N integer length of cutoff filter
// @param low_freq cutoff frequency portion for high pass
// @param high_freq cutoff frequency portion for low pass
// @param stop_value stop value for blocked frequencies
function H = ideal_bandpass(N, low_freq, high_freq, stop_value)
  N = (N - modulo(N,2)) / 2;
  low_cutoff = 1 + floor(low_freq * 2 * N);
  // low_cutoff = 1
  high_cutoff = N - floor(high_freq * 2 * N);
  // high_cutoff = N
  H = ones(1, N) * stop_value;
  H(low_cutoff : high_cutoff) = 1;
  H = [H flipdim(H, 2)];

  // shifting the frequency response
  h_len = length(H);
  frequencies = (0 : h_len - 1) / h_len * Fs;
  shifts = %e ^ (%i * %pi * frequencies);
  H = H .* shifts;
endfunction

// Ns = [32, 256, 1024, 2048];
Ns = [1024];
// lps = [0.001, 0.005, 0.01, 0.05, 0.15];
lps = [0.005];
// hps = [0.15, 0.25, 0.30, 0.32, 0.4];
hps = [0.3];

for N = Ns
  for lp = lps
    for hp = hps
      filename_suffix = '_N' + string(N) + '_lp' + string(lp) + '_hp' + string(hp);

      H_b = ideal_bandpass(N, lp, hp, 0.);

      h_len = length(H_b);
      frequencies = (0 : h_len - 1) / h_len * Fs;

      if %show_plots then
        clf();
        plot2d('nn', frequencies, H_b, color('blue'));
        xs2png(0, './01_plots/03_filter_frequencies' + filename_suffix + '.png');
      end

      h_b = real(ifft(H_b));
      h_b = h_b .* window('kr', length(h_b), 8);

      if %show_plots then
        clf();
        plot2d('nn', 0:length(h_b)-1, h_b, color("blue"));
        xs2png(0, './01_plots/04_filter_plain' + filename_suffix + '.png');
      end

      filtered = convol(h_b, signal);
      wavwrite(filtered, Fs, './01_data/filtered' + filename_suffix + '.wav');

      if %show_plots then
        clf();
        plot(filtered);
        xs2png(0, './01_plots/05_filtered_signal' + filename_suffix + '.png');
      end

      f_len = length(filtered);
      frequencies = (0 : f_len - 1) / f_len * Fs;
      filtered_freq = abs(fft(filtered));

      if %show_plots then
        clf();
        plot2d('nl', frequencies, filtered_freq, color('blue'));
        xs2png(0, './01_plots/06_filtered_signal_freq' + filename_suffix + '.png');
      end
    end
  end
end

// vim: set fdm=marker:
