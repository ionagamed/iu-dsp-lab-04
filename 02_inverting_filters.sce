// Additional helper functions {{{1 ============================================

function plot_and_save(data, filename)
  figure(0);
  clf();
  plot(data);
  xs2png(0, './02_plots/' + filename);
endfunction

Fs = 44100

// Loading the data {{{1 =======================================================

irc = loadwave('./02_data/irc.wav');
irc = irc(1, :);

track = loadwave('./02_data/sample_track.wav');
track = track(1, :);

// Inverting the IRC {{{1 ======================================================

plot_and_save(irc, '01_irc.png');

irc_fft = fft(irc);
inv_irc_fft = 1 ./ irc_fft;
inv_irc = real(ifft(inv_irc_fft));
inv_irc = inv_irc / max(inv_irc);

plot_and_save(inv_irc, '02_inv_irc.png');

// This should be just a simple Kronecker delta
kron = convol(inv_irc, irc);

plot_and_save(kron, '03_kronecker.png');

// Testing the inverted IRC on the original data {{{1 ==========================

irc_track = convol(track, irc);
irc_track = irc_track / max(irc_track);
wavwrite(irc_track, Fs, './02_data/01_irc_track.wav');

inv_irc_track = convol(irc_track, inv_irc);
inv_irc_track = inv_irc_track / max(inv_irc_track);
wavwrite(inv_irc_track, Fs, './02_data/02_inv_irc_track.wav');

// vim: set fdm=marker:
