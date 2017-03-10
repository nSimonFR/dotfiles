module.exports = {
  config: {
    fontSize: 15,
    fontFamily: 'Consolas, "Lucida Console", monospace',

    shell: 'C:\\Windows\\System32\\bash.exe',
    shellArgs: ['-c', 'cd ~; /bin/zsh'],

    env: {
      'DISPLAY': ':0',
    },

    bell: false,
    copyOnSelect: false,
    cursorBlink: true,
    windowPosition: [150, 100],
    windowSize: [1000, 600],
  },
  plugins: [],
  localPlugins: []
};
