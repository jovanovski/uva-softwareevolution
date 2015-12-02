//*******************************************************************
//  CHORD MAPPER 
//*******************************************************************
function chordMpr (data) {
  var mpr = {}, mmap = {}, n = 0, mrel = {}, grel = {},
      matrix = [], filter, accessor;

  mpr.setFilter = function (fun) {
    filter = fun;
    return this;
  },
  mpr.setAccessor = function (fun) {
    accessor = fun;
    return this;
  },
  mpr.getMatrix = function () {
    matrix = [];
    _.each(mmap, function (a) {
      if (!matrix[a.id]) matrix[a.id] = [];
      _.each(mmap, function (b) {
       var recs = _.filter(data, function (row) {
          return filter(row, a, b);
        })
        matrix[a.id][b.id] = accessor(recs, a, b);
      });
    });
    return matrix;
  },
  mpr.addConnection = function(a, b, lines){
    mrel[a + "->" + b] = lines;
    if(!grel[a]) {
      grel[a] = lines;
    }
    else {
      grel[a] = grel[a] + lines;
    }
  },
  mpr.getMap = function () {
    return mmap;
  },
  mpr.getConnections = function () {
    return mrel;
  },
  mpr.getRel = function () { return grel; },
  mpr.printMatrix = function () {
    _.each(matrix, function (elem) {
      console.log(elem);
    })
  },
  mpr.addToMap = function (value, lines, info) {
    if (!mmap[value]) {
      mmap[value] = { name: value, id: n++, data: info, lines: lines}
    }
  },
  mpr.addValuesToMap = function (varName, info) {
    var values = _.uniq(_.pluck(data, varName));
    _.map(values, function (v) {
      if (!mmap[v]) {
        mmap[v] = { name: v, id: n++, data: info }
      }

    });
    return this;
  }
  return mpr;
}
//*******************************************************************
//  CHORD READER
//*******************************************************************
function chordRdr (matrix, mmap, mrel, grel) {
  return function (d) {
    var i,j,s,t,g,m = {};
    if (d.source) {
      i = d.source.index; j = d.target.index;
      s = _.where(mmap, {id: i });
      t = _.where(mmap, {id: j });
      m.sname = s[0].name;
      m.lines = mrel[s[0].name + "->" + t[0].name];
      m.sdata = d.source.value;
      m.svalue = +d.source.value;
      m.stotal = _.reduce(matrix[i], function (k, n) { return k + n }, 0);
      m.tname = t[0].name;
      m.tdata = d.target.value;
      m.tvalue = +d.target.value;
      m.ttotal = _.reduce(matrix[j], function (k, n) { return k + n }, 0);
    } else {
      g = _.where(mmap, {id: d.index });
      m.gname = g[0].name;
      m.gdata = g[0].data;
      m.glines = g[0].lines;
      m.gvalue = d.value;
    }
    m.mtotal = _.reduce(matrix, function (m1, n1) { 
      return m1 + _.reduce(n1, function (m2, n2) { return m2 + n2}, 0);
    }, 0);
    return m;
  }
}
